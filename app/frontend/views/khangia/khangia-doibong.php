<section
    class="spectator-page spectator-teams"
    data-teams-api="<?= e(url('/api/public/teams')) ?>"
    data-detail-url="<?= e(url('/khan-gia/doi-bong/chi-tiet')) ?>"
>
    <header class="spectator-topbar">
        <div>
            <h1>Danh sách đội bóng</h1>
            <p class="sub">Danh sách các đội bóng đang hoạt động và công khai.</p>
        </div>
    </header>

    <div id="pageMessage" class="spectator-message"></div>

    <section id="empty" class="empty hidden">
        Hiện tại chưa có đội bóng nào
    </section>

    <section class="spectator-grid" id="teamList"></section>
</section>
