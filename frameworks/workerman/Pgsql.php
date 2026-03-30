<?php

class Pgsql
{
    private static ?PDOStatement $bench = null;
    private static bool $available = false;

    public static function init()
    {
        try {
            $dsn = getenv('DATABASE_URL');
            if (!$dsn) {
                self::$available = false;
                return;
            }
            // Parse postgres://user:pass@host:port/dbname
            $parts = parse_url($dsn);
            $host = $parts['host'] ?? 'localhost';
            $port = $parts['port'] ?? 5432;
            $db = ltrim($parts['path'] ?? '/benchmark', '/');
            $user = $parts['user'] ?? 'bench';
            $pass = $parts['pass'] ?? 'bench';

            $pdo = new PDO(
                "pgsql:host=$host;port=$port;dbname=$db",
                $user,
                $pass,
                [
                    PDO::ATTR_DEFAULT_FETCH_MODE  => PDO::FETCH_ASSOC,
                    PDO::ATTR_ERRMODE             => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_EMULATE_PREPARES    => false
                ]
            );
            self::$bench = $pdo->prepare(
                'SELECT id, name, category, price, quantity, active, tags, rating_score, rating_count FROM items WHERE price BETWEEN ? AND ? LIMIT 50'
            );
            self::$available = true;
        } catch (\Exception $e) {
            self::$available = false;
        }
    }

    public static function ensureConnected(): bool
    {
        if (self::$available) return true;
        self::init();
        return self::$available;
    }

    public static function query($min, $max)
    {
        if (!self::ensureConnected()) {
            return '{"items":[],"count":0}';
        }
        try {
            self::$bench->execute([$min, $max]);
            $data = [];
            while ($row = self::$bench->fetch()) {
                $data[] = [
                    'id' => $row['id'],
                    'name' => $row['name'],
                    'category' => $row['category'],
                    'price' => $row['price'],
                    'quantity' => $row['quantity'],
                    'active' => (bool) $row["active"],
                    'tags' => json_decode($row["tags"], true),
                    'rating' => [
                        "score" => $row["rating_score"],
                        "count" => $row["rating_count"]
                    ],
                ];
            }
            return json_encode(['items' => $data, 'count' => count($data)],
                                JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        } catch (\Exception $e) {
            self::$available = false;
            self::$bench = null;
            return '{"items":[],"count":0}';
        }
    }
}
