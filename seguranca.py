"""Utilitários de criptografia da senha usados pelo script e pelo main.robot.

A senha original nunca é gravada em arquivo: o script criptografa a senha
informada no terminal e imprime o texto criptografado + a semente (seed).
O .env guarda apenas esses dois valores e o main.robot descriptografa em tempo
de execução.
"""
import base64
import hashlib

from cryptography.fernet import Fernet


def _chave(seed: str) -> bytes:
    """Deriva a chave Fernet (32 bytes) a partir da semente."""
    digest = hashlib.sha256(seed.encode("utf-8")).digest()
    return base64.urlsafe_b64encode(digest)


def criptografar_senha(senha: str, seed: str) -> str:
    """Criptografa a senha e devolve o texto (token) para o .env."""
    return Fernet(_chave(seed)).encrypt(senha.encode("utf-8")).decode("utf-8")


def descriptografar_senha(token: str, seed: str) -> str:
    """Descriptografa o token do .env e devolve a senha original."""
    return Fernet(_chave(seed)).decrypt(token.encode("utf-8")).decode("utf-8")
