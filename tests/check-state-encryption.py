"""Check plaintext-state migration and the default encrypted-only boundary."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

source = Path(sys.argv[1]).read_text()
template = source.split('generate "encryption" {', 1)[1].split('<<-EOF', 1)[1].split('\n  EOF', 1)[0]
environment = os.environ.copy()
environment['TF_VAR_tofu_state_passphrase'] = 'offline-encryption-fixture-passphrase-only'
sentinel = 'harmless state encryption fixture'
base = '''variable "tofu_state_passphrase" { type = string }
resource "terraform_data" "fixture" { input = "harmless state encryption fixture" }
'''

def configuration(migrate):
    return base + template.replace('${!local.state_migration}', 'false' if migrate else 'true').replace('${local.state_migration ? "fallback { method = method.unencrypted.migration }" : ""}', 'fallback { method = method.unencrypted.migration }' if migrate else '')

with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    config = root / 'main.tf'
    def run(args, data=None, success=True):
        result = subprocess.run(['tofu', *args], cwd=root, env=environment, input=data, capture_output=True)
        if success and result.returncode:
            raise RuntimeError('Fixture command failed: ' + ' '.join(args) + '\n' + result.stderr.decode())
        return result
    config.write_text(base)
    run(['init', '-backend=false'])
    run(['apply', '-auto-approve'])
    state = root / 'terraform.tfstate'
    original = state.read_bytes()
    original_data = json.loads(original)
    config.write_text(configuration(True))
    run(['state', 'push', '-'], original)
    encrypted = state.read_bytes()
    assert 'encryption_version' in json.loads(encrypted)
    assert sentinel.encode() not in encrypted
    config.write_text(configuration(False))
    restored = json.loads(run(['state', 'pull']).stdout)
    assert restored['resources'] == original_data['resources']
    assert restored['lineage'] == original_data['lineage']
    run(['plan', '-out=fixture.plan'])
    assert sentinel.encode() not in (root / 'fixture.plan').read_bytes()
    state.write_bytes(original)
    rejected = run(['state', 'pull'], success=False)
    assert rejected.returncode != 0, 'Default configuration accepted plaintext state'
    assert state.read_bytes() == original, 'Rejected read modified existing state'
print('State migration roundtrip, encrypted plans and plaintext rejection passed')
