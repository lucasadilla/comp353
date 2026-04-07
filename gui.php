<?php
// index.php
// Simple web GUI to view and run SQL against a MySQL database using PDO.

// ---------- DB CONFIG ----------
$dbHost = getenv('MYSQL_HOST') ?: 'ixc353.encs.concordia.ca';
$dbPort = getenv('MYSQL_PORT') ?: '3306';
$dbUser = getenv('MYSQL_USER') ?: 'ixc353_4';
$dbPass = getenv('MYSQL_PASSWORD') ?: 'SqlAcc26w';
$dbName = getenv('MYSQL_DATABASE') ?: 'ixc353_4';

$dsn = "mysql:host={$dbHost};port={$dbPort};dbname={$dbName};charset=utf8mb4";
$options = [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
];

try {
    $pdo = new PDO($dsn, $dbUser, $dbPass, $options);
} catch (PDOException $e) {
    http_response_code(500);
    echo "<h1>Database connection error</h1>";
    echo "<pre>" . htmlspecialchars($e->getMessage()) . "</pre>";
    exit;
}

// ---------- Helpers ----------
function fetch_table_names(PDO $pdo) {
    $sql = "
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = DATABASE()
        ORDER BY table_name
    ";
    $stmt = $pdo->query($sql);
    return $stmt->fetchAll(PDO::FETCH_COLUMN);
}

function is_select_query(string $q): bool {
    $q = ltrim($q);
    return strncasecmp($q, 'select', 6) === 0;
}

function safe_identifier(string $name): string {
    // Very small sanitizer for identifiers: allow letters, numbers, underscore, dot
    // If it contains other chars, return empty to avoid injection.
    if (preg_match('/^[A-Za-z0-9_\.]+$/', $name)) {
        // backtick each part (for schema.table)
        $parts = explode('.', $name);
        $parts = array_map(function($p){ return "`$p`"; }, $parts);
        return implode('.', $parts);
    }
    return '';
}

// ---------- Request handling ----------
$tables = fetch_table_names($pdo);
$selectedTable = $_POST['table'] ?? '';
$queryText = $_POST['query'] ?? '';
$action = $_POST['action'] ?? '';

$messages = [];
$results = null;
$columns = [];

if ($action === 'load_table' && $selectedTable) {
    $ident = safe_identifier($selectedTable);
    if ($ident === '') {
        $messages[] = ['type'=>'error','text'=>'Invalid table name.'];
    } else {
        $queryText = "SELECT * FROM {$ident} LIMIT 100";
        $action = 'run_query';
    }
}

if ($action === 'run_query' && trim($queryText) !== '') {
    try {
        if (is_select_query($queryText)) {
            $stmt = $pdo->query($queryText);
            $results = $stmt->fetchAll();
            $columns = $stmt->columnCount() ? array_map(function($c) use ($stmt) {
                $meta = $stmt->getColumnMeta($c);
                return $meta['name'] ?? "col{$c}";
            }, range(0, $stmt->columnCount()-1)) : [];
            $messages[] = ['type'=>'success','text'=>'Query executed. Rows returned: ' . count($results)];
        } else {
            $affected = $pdo->exec($queryText);
            $messages[] = ['type'=>'success','text'=>"Non-SELECT query executed. Affected rows: {$affected}"];
        }
    } catch (PDOException $e) {
        $messages[] = ['type'=>'error','text'=>$e->getMessage()];
    }
} elseif ($action === 'run_query' && trim($queryText) === '') {
    $messages[] = ['type'=>'warning','text'=>'Please enter a query.'];
}

// ---------- HTML output ----------
?>
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Rentruck Database Viewer (PHP)</title>
<meta name="viewport" content="width=device-width,initial-scale=1">
<style>
    body { font-family: Arial, sans-serif; margin: 18px; }
    .controls { display:flex; gap:12px; align-items:center; margin-bottom:12px; flex-wrap:wrap; }
    select, textarea, input[type="text"] { font-family: monospace; }
    textarea { width: 100%; min-height: 120px; }
    table { border-collapse: collapse; width: 100%; margin-top: 12px; }
    th, td { border: 1px solid #ccc; padding: 6px 8px; text-align: left; vertical-align: top; }
    th { background:#f2f2f2; }
    .msg { padding:8px; margin:8px 0; border-radius:4px; }
    .msg.success { background:#e6ffed; border:1px solid #b7f0c6; }
    .msg.error { background:#ffecec; border:1px solid #f5c2c2; }
    .msg.warning { background:#fff7e6; border:1px solid #f0d9b7; }
    .small { font-size:0.9em; color:#666; }
    .actions { display:flex; gap:8px; }
</style>
</head>
<body>
<h1>Rentruck Database Viewer (PHP)</h1>

<?php foreach ($messages as $m): ?>
    <div class="msg <?=htmlspecialchars($m['type'])?>"><?=nl2br(htmlspecialchars($m['text']))?></div>
<?php endforeach; ?>

<form method="post" style="margin-bottom:12px;">
    <div class="controls">
        <div>
            <label><strong>Table</strong><br>
                <select name="table">
                    <option value="">-- select table --</option>
                    <?php foreach ($tables as $t): ?>
                        <option value="<?=htmlspecialchars($t)?>" <?= $t === $selectedTable ? 'selected' : '' ?>><?=htmlspecialchars($t)?></option>
                    <?php endforeach; ?>
                </select>
            </label>
        </div>

        <div class="actions">
            <button type="submit" name="action" value="load_table">Load Table</button>
        </div>
    </div>

    <div>
        <label><strong>Enter SQL Query</strong></label>
        <textarea name="query" placeholder="SELECT * FROM table LIMIT 100"><?=htmlspecialchars($queryText)?></textarea>
    </div>

    <div style="margin-top:8px;">
        <button type="submit" name="action" value="run_query">Run Query</button>
        <button type="submit" name="action" value="clear" onclick="document.querySelector('textarea[name=query]').value='';">Clear</button>
    </div>
</form>

<?php if (is_array($results)): ?>
    <h2>Results (<?=count($results)?> rows)</h2>
    <?php if (count($results) === 0): ?>
        <div class="small">Query returned no rows.</div>
    <?php else: ?>
        <table>
            <thead>
                <tr>
                    <?php
                    // If column names are empty, derive from first row keys
                    if (empty($columns)) {
                        $columns = array_keys($results[0]);
                    }
                    foreach ($columns as $col): ?>
                        <th><?=htmlspecialchars($col)?></th>
                    <?php endforeach; ?>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($results as $row): ?>
                    <tr>
                        <?php foreach ($columns as $col): ?>
                            <td><?=htmlspecialchars((string)($row[$col] ?? ''))?></td>
                        <?php endforeach; ?>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    <?php endif; ?>
<?php endif; ?>

</body>
</html>
