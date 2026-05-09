<?php

declare(strict_types=1);

namespace App\Backend\Controllers;

use App\Backend\Core\Controller;
use App\Backend\Core\Http\Request;
use App\Backend\Core\Http\Response;

final class SpectatorPageController extends Controller
{
    public function teams(Request $request): Response
    {
        return $this->page('khangia.teams', 'VTMS - Danh sach doi bong', 'spectator-teams.js');
    }

    public function teamDetail(Request $request): Response
    {
        return $this->page('khangia.team-detail', 'VTMS - Thong tin doi bong', 'spectator-team-detail.js');
    }

    public function schedule(Request $request): Response
    {
        return $this->page('khangia.schedule', 'VTMS - Lich thi dau', 'spectator-schedule.js');
    }

    public function results(Request $request): Response
    {
        return $this->page('khangia.results', 'VTMS - Ket qua tran dau', 'spectator-results.js');
    }

    public function standings(Request $request): Response
    {
        return $this->page('khangia.standings', 'VTMS - Bang xep hang', 'spectator-standings.js');
    }

    private function page(string $view, string $title, string $script): Response
    {
        return $this->view($view, [
            'pageTitle' => $title,
            'styles' => ['css/spectator-pages.css'],
            'scripts' => ['js/spectator-common.js', 'js/' . $script],
        ]);
    }
}
