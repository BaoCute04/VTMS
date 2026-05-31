<?php

declare(strict_types=1);

namespace App\Backend\Controllers\Spectator;

use App\Backend\Core\Auth\Auth;
use App\Backend\Core\Controller;
use App\Backend\Core\Http\Request;
use App\Backend\Core\Http\Response;
use App\Backend\Services\Spectator\SpectatorClubInfoService;

final class SpectatorClubInfoController extends Controller
{
    private SpectatorClubInfoService $service;

    public function __construct()
    {
        $this->service = new SpectatorClubInfoService();
    }

    public function show(Request $request): Response
    {
        $teamId = $this->routePositiveInt($request, 'teamId');

        if ($teamId === null) {
            return $this->notFound('Khong tim thay cau lac bo.');
        }

        return $this->respond($this->service->show($teamId, $this->accountId(), $request));
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
        $payload = [
            'success' => $result['ok'],
            'message' => $result['message'],
        ];

        if (array_key_exists('club', $result)) {
            $payload['data'] = $result['club'];
        }

        foreach (['members', 'tournaments'] as $key) {
            if (array_key_exists($key, $result)) {
                $payload[$key] = $result[$key];
            }
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

