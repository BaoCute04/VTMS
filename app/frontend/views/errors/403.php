<section class="error-page">
    <h1>403</h1>
    <p>Ban khong co quyen truy cap chuc nang nay.</p>
    <?php if (!empty($requiredRoles)): ?>
        <p class="hint">Vai tro yeu cau: <?= e(implode(', ', $requiredRoles)) ?></p>
    <?php endif; ?>
    <a class="button" href="<?= e(url('/dashboard')) ?>">Quay lai dashboard</a>
</section>
