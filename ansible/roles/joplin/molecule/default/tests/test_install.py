import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_joplin_appimage(host):
    appimage = host.file("/home/test_usr1/.joplin/Joplin.AppImage")

    assert appimage.exists
