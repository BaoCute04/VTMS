<?php

$links = [
    ['label' => 'Quan tri', 'href' => '/admin', 'roles' => ['ADMIN']],
    ['label' => 'Quan ly tai khoan', 'href' => '/admin/users', 'roles' => ['ADMIN']],
    ['label' => 'Quan ly nguoi dung', 'href' => '/admin/nguoi-dung', 'roles' => ['ADMIN']],
    ['label' => 'Ban to chuc', 'href' => '/ban-to-chuc', 'roles' => ['BAN_TO_CHUC', 'ADMIN']],
    ['label' => 'Trong tai', 'href' => '/trong-tai', 'roles' => ['TRONG_TAI', 'ADMIN']],
    ['label' => 'Huan luyen vien', 'href' => '/huan-luyen-vien', 'roles' => ['HUAN_LUYEN_VIEN', 'ADMIN']],
    ['label' => 'Van dong vien', 'href' => '/van-dong-vien', 'roles' => ['VAN_DONG_VIEN', 'ADMIN']],
    ['label' => 'Khan gia', 'href' => '/khan-gia', 'roles' => ['KHAN_GIA', 'ADMIN']],
];
?>
<section class="dashboard-head">
    <p class="eyebrow"><?= e($user['role'] ?? '') ?></p>
    <h1><?= e($moduleTitle) ?></h1>
    <p class="lead"><?= e($moduleDescription) ?></p>
</section>

<section class="grid">
    <?php foreach ($links as $link): ?>
        <?php if (in_array($user['role'] ?? '', $link['roles'], true)): ?>
            <a class="card link-card" href="<?= e(url($link['href'])) ?>">
                <h2><?= e($link['label']) ?></h2>
                <p>Mo phan chuc nang danh cho vai tro hien tai.</p>
            </a>
        <?php endif; ?>
    <?php endforeach; ?>
</section>
