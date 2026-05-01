<?php

use App\Backend\Core\Auth\Auth;

$authUser = Auth::user();
?>
<!doctype html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?= e(config('app.name', 'VTMS')) ?></title>
    <link rel="stylesheet" href="<?= e(asset('css/app.css')) ?>">
</head>
<body>
    <header class="topbar">
        <a class="brand" href="<?= e(url('/')) ?>">VTMS</a>
        <nav class="nav">
            <a href="<?= e(url('/')) ?>">Trang chu</a>
            <?php if ($authUser): ?>
                <a href="<?= e(url('/dashboard')) ?>">Dashboard</a>
                <form method="post" action="<?= e(url('/logout')) ?>" class="inline-form">
                    <?= csrf_field() ?>
                    <button type="submit">Dang xuat</button>
                </form>
            <?php else: ?>
                <a href="<?= e(url('/login')) ?>">Dang nhap</a>
            <?php endif; ?>
        </nav>
    </header>

    <main class="page">
        <?= $content ?>
    </main>
</body>
</html>
