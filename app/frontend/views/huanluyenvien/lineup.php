<section
    class="coach-page coach-lineup"
    data-teams-api="<?= e(url('/api/coach/teams')) ?>"
    data-registrations-api="<?= e(url('/api/coach/tournament-registrations')) ?>"
>
    <header class="coach-topbar">
        <div>
            <p class="eyebrow">HUẤN LUYỆN VIÊN</p>
            <h1>Đội hình thi đấu</h1>
            <p class="sub">Xem danh sách đội hình đã tạo theo đội bóng và giải đấu.</p>
        </div>
        <a class="btn primary" href="<?= e(url('/huan-luyen-vien/doi-hinh/chinh-sua')) ?>">Tạo / Cập nhật đội hình</a>
    </header>

    <section class="coach-toolbar">
        <select id="teamSelect"></select>
        <select id="tournamentSelect"></select>
        <button id="btnRefresh" class="btn" type="button">Làm mới</button>
    </section>

    <div id="pageMessage" class="coach-message"></div>

    <section class="coach-card" id="lineupInfo">
        <p class="empty">Chọn đội và giải đấu để xem đội hình.</p>
    </section>
</section>
