"""Gera a semente e o texto criptografado da senha do e-mail.

Uso:
    uv run python criptografar_senha.py

Depois, cole os dois valores impressos no arquivo .env:
    CANVAS_SENHA_SEED=<seed>
    CANVAS_SENHA_CRYPT=<token>

Observação de segurança: a semente fica junto com o texto criptografado no
mesmo .env, então isso é uma ofuscação (impede a senha de aparecer "em texto
puro" no arquivo), e não uma proteção contra quem tiver acesso ao .env.
"""
import getpass
import secrets
import sys

from seguranca import criptografar_senha


def _pedir_senha() -> str:
    try:
        return getpass.getpass("Digite sua senha (não será exibida): ")
    except (EOFError, KeyboardInterrupt):
        print("\nOperação cancelada.")
        sys.exit(1)


def main() -> None:
    senha = _pedir_senha()
    if not senha:
        print("A senha não pode ser vazia.")
        sys.exit(1)

    seed = secrets.token_urlsafe(32)
    token = criptografar_senha(senha, seed)

    print("\nCole no seu arquivo .env:\n")
    print(f"CANVAS_SENHA_SEED={seed}")
    print(f"CANVAS_SENHA_CRYPT={token}")
    print("\nA senha original não foi armazenada em lugar nenhum.")


if __name__ == "__main__":
    main()
