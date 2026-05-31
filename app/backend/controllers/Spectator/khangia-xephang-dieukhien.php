<?php

declare(strict_types=1);

namespace App\Backend\Controllers\Spectator;

use App\Backend\Core\Auth\Auth;
use App\Backend\Core\Controller;
use App\Backend\Core\Http\Request;
use App\Backend\Core\Http\Response;
use App\Backend\Services\Spectator\SpectatorStandingService;

final class SpectatorStandingController extends Controller
{
    private SpectatorStandingService $service;

    public function __construct()
    {
        $this->service = new SpectatorStandingService();
    }

    public function index(Request $request): Response
    {
        return $this->respond($this->service->all($this->accountId(), [
            'q' => $request->query('q', $request->query('keyword', '')),
            'tournament_id' => $request->query('tournament_id', $request->query('idgiaidau', null)),
        ], $request));
    }

    public function show(Request $request): Response
    {
        $rankingId = $this->routePositiveInt($request, 'rankingId');

        if ($rankingId === null) {
            return $this->notFound('Khong tim thay bang xep hang.');
        }

        return $this->respond($this->service->show($rankingId, $this->accountId(), $request));
    }

    public function latestByTournament(Request $request): Response
    {
        $tournamentId = $this->routePositiveInt($request, 'tournamentId');

        if ($tournamentId === null) {
            return $this->notFound('Khong tim thay giai dau.');
        }

        return $this->respond($this->service->latestByTournament($tournamentId, $this->accountId(), $request));
    }

    private function accountId(): int
    {
        return (int) (Auth::user()['id'] ?? 0);
    }

    private function routePositiveInt(Request $request, string $key): ?int
    {
        $raw = (string) $request->route($key, $request->route('id', ''));

        if ($raw === '' || !ctype_digit($raw)) {
            return null;
        }

        $id = (int) $raw;

        return $id > 0 ? $id : null;
    }

    private function respond(array $result): Response
    {
        $payload = ['success' => $result['ok'], 'message' => $result['message']];

        foreach (['standings', 'standing'] as $key) {
            if (array_key_exists($key, $result)) {
                $payload['data'] = $result[$key];
                break;
            }
        }

        if (array_key_exists('rows', $result)) {
            $payload['rows'] = $result['rows'];
        }

        if (array_key_exists('meta', $result)) {
            $payload['meta'] = $result['meta'];
        }

        if (!empty($result['errors'])) {
            $payload['errors'] = $result['errors'];
        }

        return Response::json($payload, (int) $result['status']);
    }

    private function notFound(string $message): Response
    {
        return Response::json(['success' => false, 'message' => $message], 404);
    }
}

