<section class="hero">
    <div>
        <p class="eyebrow">Volleyball Tournament Management System</p>
        <h1>He thong quan ly giai dau bong chuyen</h1>
        <p class="lead">Nen tang MVC monolithic de quan ly giai dau, doi bong, lich thi dau, trong tai, ket qua va thong ke.</p>
        <div class="actions">
            <?php if ($user): ?>
                <a class="button primary" href="<?= e(url('/dashboard')) ?>">Vao dashboard</a>
            <?php else: ?>
                <a class="button primary" href="<?= e(url('/login')) ?>">Dang nhap</a>
            <?php endif; ?>
        </div>
    </div>
</section>

<section class="grid">
    <article class="card">
        <h2>MVC + Service Layer</h2>
        <p>Controller dieu phoi request, service xu ly nghiep vu, model lam viec voi CSDL, view hien thi giao dien.</p>
    </article>
    <article class="card">
        <h2>Role Middleware</h2>
        <p>Cac man hinh rieng duoc bao ve theo vai tro: admin, ban to chuc, trong tai, huan luyen vien va van dong vien.</p>
    </article>
    <article class="card">
        <h2>Front Controller</h2>
        <p>Moi request di qua public/index.php, giup kiem soat luong chay va tranh truy cap truc tiep vao backend.</p>
    </article>
</section>
