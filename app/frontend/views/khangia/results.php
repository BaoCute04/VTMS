<section
    class="spectator-page spectator-results"
    data-results-api="<?= e(url('/api/public/results')) ?>"
>
    <header class="spectator-topbar">
        <div>
            <h1>Kết quả trận đấu</h1>
            <p class="sub">Chỉ hiển thị kết quả đã được công bố.</p>
        </div>
    </header>

    <section id="empty" class="empty hidden">
        Chưa có kết quả trận đấu được công bố
    </section>

    <div class="table-wrap">
        <table class="spectator-table" id="resultTable">
            <thead>
                <tr>
                    <th>Giải đấu</th>
                    <th>Vòng</th>
                    <th>Trận đấu</th>
                    <th>Tỉ số</th>
                    <th>Thời gian</th>
                </tr>
            </thead>
            <tbody id="tbody">
                <tr><td colspan="5" class="empty">Đang tải dữ liệu...</td></tr>
            </tbody>
        </table>
    </div>
</section>
