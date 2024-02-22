import http from 'k6/http';
import { sleep, check } from 'k6';
import { SharedArray } from 'k6/data';

// Helper functions for dynamic data
function randomClienteId() {
    return Math.floor(Math.random() * 5) + 1;
}

function randomValorTransacao() {
    return Math.floor(Math.random() * 10000) + 1;
}

function randomDescricao() {
    let result = '';
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    for (let i = 0; i < 10; i++ ) {
        result += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    return result;
}

// Validation logic
function validarConsistenciaSaldoLimite(response) {
    // Assume response.json('saldo') and response.json('limite') correctly extract the values
    let saldo = response.json('saldo');
    let limite = response.json('limite');
    if (!saldo || !limite) return false; // Basic check to ensure data exists

    // Convert to integers if they're not already (depending on your API response format)
    saldo = parseInt(saldo, 10);
    limite = parseInt(limite, 10);

    // Perform the validation logic
    return saldo >= -1 * limite;
}

const baseUrl = 'http://localhost:9999';

export let options = {
    scenarios: {
        creditos: {
            executor: 'ramping-vus',
            startVUs: 0,
            stages: [
                { duration: '30s', target: 110 }, // simulate ramp up of traffic from 1 to 110 users over 2 minutes
                { duration: '30s', target: 110 }, // stay at 110 users for 2 minutes
            ],
            gracefulRampDown: '60s',
            exec: 'creditos', // name of the function to execute
        },
        debitos: {
            executor: 'ramping-vus',
            startVUs: 0,
            stages: [
                { duration: '20s', target: 220 }, // simulate ramp up of traffic from 1 to 220 users over 2 minutes
                { duration: '20s', target: 220 }, // stay at 220 users for 2 minutes
            ],
            gracefulRampDown: '60s',
            exec: 'debitos',
        },
        extratos: {
            executor: 'ramping-vus',
            startVUs: 0,
            stages: [
                { duration: '30s', target: 10 }, // simulate ramp up of traffic from 1 to 10 users over 2 minutes
                { duration: '20s', target: 10 }, // stay at 10 users for 2 minutes
            ],
            gracefulRampDown: '60s',
            exec: 'extratos',
        },
    },
};

function createTransactionPayload(valor, tipo, descricao) {
    return JSON.stringify({
        valor,
        tipo,
        descricao,
    });
}

export function creditos() {
    const clienteId = randomClienteId();
    const valor = randomValorTransacao();
    const descricao = randomDescricao();
    const payload = createTransactionPayload(valor, 'c', descricao);
    const params = {
        headers: {
            'Content-Type': 'application/json',
        },
    };

    const res = http.post(`${baseUrl}/clientes/${clienteId}/transacoes`, payload, params);

    check(res, {
        'is status 200': (r) => r.status === 200,
        'validar consistencia saldo limite': () => validarConsistenciaSaldoLimite(res),
    });

    sleep(1);
}

export function debitos() {
    const clienteId = randomClienteId();
    const valor = randomValorTransacao();
    const descricao = randomDescricao();
    const payload = createTransactionPayload(valor, 'd', descricao);
    const params = {
        headers: {
            'Content-Type': 'application/json',
        },
    };

    const res = http.post(`${baseUrl}/clientes/${clienteId}/transacoes`, payload, params);

    check(res, {
        'is status 200 or 422': (r) => [200, 422].includes(r.status),
        'validar consistencia saldo limite': () => validarConsistenciaSaldoLimite(res),
    });

    sleep(1);
}

export function extratos() {
    const clienteId = randomClienteId();
    const res = http.get(`${baseUrl}/clientes/${clienteId}/extrato`);

    check(res, {
        'is status 200': (r) => r.status === 200,
        'validar consistencia saldo limite': () => validarConsistenciaSaldoLimite(res),
    });

    sleep(1);
}

