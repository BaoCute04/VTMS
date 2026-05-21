<section
    class="organizer-teams"
    data-eligibility-api="<?= e(url('/api/organizer/higher-eligibility')) ?>"
>
    <header class="teams-topbar">
        <div>
            <p class="eyebrow">BAN TỔ CHỨC</p>
            <h1>Tư cách tham gia cấp trên</h1>
            <p class="sub">Xét đội vô địch đủ điều kiện, đề cử lên BTC cấp cao hơn và xác nhận đề cử gửi đến.</p>
        </div>
    </header>

    <section class="teams-toolbar" aria-label="Bộ lọc tư cách tham gia">
        <input id="q" type="text" placeholder="Tìm đội bóng / giải nguồn / giải cấp trên" />
        <button id="btnRefresh" class="btn" type="button">Làm mới</button>
    </section>

    <section>
        <h2 class="section-title">Đội vô địch có thể đề cử</h2>
        <div class="teams-table-wrap">
            <table class="teams-table">
                <thead>
                    <tr>
                        <th>Đội bóng</th>
                        <th>Thành tích nguồn</th>
                        <th>Giải cấp trên</th>
                        <th>BTC nhận</th>
                        <th>Trạng thái</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody id="candidateBody">
                    <tr>
                        <td colspan="6" class="empty">Đang tải dữ liệu...</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </section>

    <section>
        <h2 class="section-title">Đề cử gửi đến BTC hiện tại</h2>
        <div class="teams-table-wrap">
            <table class="teams-table">
                <thead>
                    <tr>
                        <th>Đội bóng</th>
                        <th>BTC đề cử</th>
                        <th>Thành tích nguồn</th>
                        <th>Giải cấp trên</th>
                        <th>Trạng thái</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody id="incomingBody">
                    <tr>
                        <td colspan="6" class="empty">Đang tải dữ liệu...</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </section>

    <p class="teams-message" id="pageMessage" role="status"></p>
</section>
