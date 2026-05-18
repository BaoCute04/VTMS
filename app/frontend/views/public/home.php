<section class="hero">
    <div>
        <p class="eyebrow">Volleyball Tournament Management System</p>
        <h1>Hệ thống quản lý giải đấu bóng chuyền</h1>
        <p class="lead">Nền tảng MVC monolithic để quản lý giải đấu, đội bóng, lịch thi đấu, trọng tài, kết quả và thống kê.</p>
        <div class="actions">
            <?php if ($user): ?>
                <a class="button primary" href="<?= e(url('/dashboard')) ?>">Vào dashboard</a>
            <?php else: ?>
                <a class="button primary" href="<?= e(url('/login')) ?>">Đăng nhập</a>
            <?php endif; ?>
        </div>
    </div>
</section>

<section class="grid">
    <article class="card">
        <h2>MVC + Service Layer</h2>
        <p>Controller điều phối request, service xử lý nghiệp vụ, model làm việc với CSDL, view hiển thị giao diện.</p>
    </article>
    <article class="card">
        <h2>Role Middleware</h2>
        <p>Các màn hình riêng được bảo vệ theo vai trò: admin, ban tổ chức, trọng tài, huấn luyện viên và vận động viên.</p>
    </article>
    <article class="card">
        <h2>Front Controller</h2>
        <p>Mọi request đi qua public/index.php, giúp kiểm soát luồng chạy và tránh truy cập trực tiếp vào backend.</p>
    </article>
</section>
