<section
    class="spectator-page spectator-team-detail"
    data-teams-api="<?= e(url('/api/public/teams')) ?>"
>
    <header class="spectator-topbar">
        <div>
            <h1>Thông tin đội bóng</h1>
            <p class="sub">Thông tin câu lạc bộ, huấn luyện viên và các giải đấu đã tham gia.</p>
        </div>
        <a class="spectator-card" href="<?= e(url('/khan-gia/doi-bong')) ?>">Danh sách đội bóng</a>
    </header>

    <div id="pageMessage" class="spectator-message"></div>

    <section class="spectator-card team" id="teamCard">
        <img id="logo" class="logo" alt="">
        <h2 id="name">—</h2>
        <p class="location" id="location">—</p>
    </section>

    <section class="spectator-card">
        <h3>Giới thiệu đội bóng</h3>
        <p id="description">—</p>
    </section>

    <section class="spectator-card">
        <h3>Thông tin thi đấu</h3>
        <ul>
            <li><b>Môn thể thao:</b> <span id="sport">Bóng chuyền</span></li>
            <li><b>Giải đấu:</b> <span id="tournament">—</span></li>
            <li><b>Huấn luyện viên:</b> <span id="coach">—</span></li>
        </ul>
    </section>

    <section class="spectator-card">
        <h3>Thành viên đội bóng</h3>
        <div class="table-wrap">
            <table class="spectator-table">
                <thead>
                    <tr>
                        <th>Họ tên</th>
                        <th>Vai trò</th>
                        <th>Vị trí</th>
                    </tr>
                </thead>
                <tbody id="members">
                    <tr><td colspan="3" class="empty">—</td></tr>
                </tbody>
            </table>
        </div>
    </section>

    <section id="notFound" class="empty hidden">
        Đội bóng không tồn tại hoặc không công khai
    </section>
</section>
