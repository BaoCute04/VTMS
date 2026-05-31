<section
    class="spectator-page spectator-standings"
    data-standings-api="<?= e(url('/api/public/standings')) ?>"
>
    <header class="spectator-topbar">
        <div>
            <h1>Bảng xếp hạng</h1>
            <p class="sub" id="standingSub">Bảng xếp hạng đã được công bố mới nhất.</p>
        </div>
    </header>

    <section id="empty" class="empty hidden">
        Chưa có bảng xếp hạng được công bố
    </section>

    <div class="table-wrap">
        <table class="spectator-table center" id="standingTable">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Đội bóng</th>
                    <th>Trận</th>
                    <th>Thắng</th>
                    <th>Thua</th>
                    <th>Hiệu số</th>
                    <th>Điểm</th>
                </tr>
            </thead>
            <tbody id="tbody">
                <tr><td colspan="7" class="empty">Đang tải dữ liệu...</td></tr>
            </tbody>
        </table>
    </div>
</section>
