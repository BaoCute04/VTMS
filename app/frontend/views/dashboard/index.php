<?php

$links = [
    ['label' => 'Quan tri', 'href' => '/admin', 'roles' => ['ADMIN']],
    ['label' => 'Quan ly tai khoan', 'href' => '/admin/users', 'roles' => ['ADMIN']],
    ['label' => 'Quan ly nguoi dung', 'href' => '/admin/nguoi-dung', 'roles' => ['ADMIN']],
    ['label' => 'Nhat ky he thong', 'href' => '/admin/logs', 'roles' => ['ADMIN']],
    ['label' => 'Xac nhan thong tin BTC', 'href' => '/admin/xac-nhan-thong-tin-btc', 'roles' => ['ADMIN']],
    ['label' => 'Ban to chuc', 'href' => '/ban-to-chuc', 'roles' => ['BAN_TO_CHUC', 'ADMIN']],
    ['label' => 'Quan ly giai dau', 'href' => '/ban-to-chuc/giai-dau', 'roles' => ['BAN_TO_CHUC']],
    ['label' => 'Ho so doi bong tham gia', 'href' => '/ban-to-chuc/doi-bong', 'roles' => ['BAN_TO_CHUC']],
    ['label' => 'Quan ly trong tai', 'href' => '/ban-to-chuc/trong-tai', 'roles' => ['BAN_TO_CHUC']],
    ['label' => 'Quan ly tu cach HLV', 'href' => '/ban-to-chuc/huan-luyen-vien', 'roles' => ['BAN_TO_CHUC']],
    ['label' => 'Quan ly tu cach VDV', 'href' => '/ban-to-chuc/van-dong-vien', 'roles' => ['BAN_TO_CHUC']],
    ['label' => 'Quan ly san dau', 'href' => '/ban-to-chuc/san-dau', 'roles' => ['BAN_TO_CHUC']],
    ['label' => 'Quan ly lich thi dau', 'href' => '/ban-to-chuc/lich-thi-dau', 'roles' => ['BAN_TO_CHUC']],
    ['label' => 'Quan ly khieu nai', 'href' => '/ban-to-chuc/khieu-nai', 'roles' => ['BAN_TO_CHUC']],
    ['label' => 'Quan ly ket qua tran dau', 'href' => '/ban-to-chuc/ket-qua', 'roles' => ['BAN_TO_CHUC']],
    ['label' => 'Quan ly xep hang', 'href' => '/ban-to-chuc/xep-hang', 'roles' => ['BAN_TO_CHUC']],
    ['label' => 'Xac nhan thong tin ca nhan', 'href' => '/ban-to-chuc/xac-nhan-thong-tin-ca-nhan', 'roles' => ['BAN_TO_CHUC']],
    ['label' => 'Trong tai', 'href' => '/trong-tai', 'roles' => ['TRONG_TAI', 'ADMIN']],
    ['label' => 'Lich phan cong tran dau', 'href' => '/trong-tai/lich-phan-cong', 'roles' => ['TRONG_TAI']],
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
