<?php

declare(strict_types=1);

namespace App\Backend\Controllers;

use App\Backend\Core\Auth\Auth;
use App\Backend\Core\Controller;
use App\Backend\Core\Http\Request;
use App\Backend\Core\Http\Response;
use App\Backend\Services\SpectatorTeamListService;

final class SpectatorTeamListController extends Controller
{
    private SpectatorTeamListService $service;

    public function __construct()
    {
        $this->service = new SpectatorTeamListService();
    }

    public function index(Request $request): Response
    {
        return $this->respond($this->service->all($this->accountId(), [
            'q' => $request->query('q', $request->query('keyword', '')),
            'tournament_id' => $request->query('tournament_id', $request->query('idgiaidau', null)),
            'local' => $request->query('local', $request->query('diaphuong', '')),
        ], $request));
    }

    private function accountId(): int
    {
        return (int) (Auth::user()['id'] ?? 0);
    }

    private function respond(array $result): Response
    {
        $payload = [
            'success' => $result['ok'],
            'message' => $result['message'],
        ];

        if (array_key_exists('teams', $result)) {
            $payload['data'] = $result['teams'];
        }

        if (array_key_exists('meta', $result)) {
            $payload['meta'] = $result['meta'];
        }

        if (!empty($result['errors'])) {
            $payload['errors'] = $result['errors'];
        }

        return Response::json($payload, (int) $result['status']);
    }
}
