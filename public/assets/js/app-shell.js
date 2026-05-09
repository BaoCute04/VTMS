(function () {
    const sidebar = document.querySelector('[data-app-sidebar]');
    const overlay = document.querySelector('[data-app-overlay]');
    const menuButton = document.querySelector('[data-app-menu]');
    const searchInput = document.querySelector('[data-app-search]');
    const content = document.querySelector('[data-app-content]');

    function closeSidebar() {
        sidebar?.classList.remove('open');
        overlay?.classList.remove('show');
    }

    function openSidebar() {
        sidebar?.classList.add('open');
        overlay?.classList.add('show');
    }

    menuButton?.addEventListener('click', () => {
        if (sidebar?.classList.contains('open')) {
            closeSidebar();
            return;
        }
        openSidebar();
    });

    overlay?.addEventListener('click', closeSidebar);

    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape') {
            closeSidebar();
        }
    });

    function filterRowsAndCards(keyword) {
        if (!content) {
            return;
        }

        const rows = content.querySelectorAll('tbody tr');
        const cards = content.querySelectorAll('.link-card, .coach-card, .athlete-card, .spectator-card, .team-card, .dashboard-action-card, .dashboard-stat-card, .dashboard-panel');
        const normalized = keyword.trim().toLowerCase();

        rows.forEach((row) => {
            row.hidden = normalized !== '' && !row.textContent.toLowerCase().includes(normalized);
        });

        cards.forEach((card) => {
            card.hidden = normalized !== '' && !card.textContent.toLowerCase().includes(normalized);
        });
    }

    searchInput?.addEventListener('input', (event) => {
        filterRowsAndCards(event.target.value || '');
    });
})();
