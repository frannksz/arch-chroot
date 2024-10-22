# Arch Install Chroot Shell Script

Esse script é a continuação do [arch-install](https://github.com/frannksz/arch-install), só que esse roda dentro do chroot.

### ATENÇÃO
- TOTALMENTE RECOMENDO ler a [wiki](https://wiki.archlinux.org/title/Installation_guide)
- CUIDADO tudo que acontece dentro do chroot afeta diretamente dentro do seu sistema.
- RECOMENDO MAIS UMA VEZ... LEIA O SCRIPT ANTES DE EXECUTA-LO.
- NÃO me responsabilizo por danos.
- Fique a vontade em alterar o script ao seu gosto/uso.

### Download/Execução:

Logo após de ter executado com êxito o [script anterior](https://github.com/frannksz/arch-install), entre dentro do chroot e execute esse, com esses comandos:

``` sh
arch-chroot /mnt
wget -c "https://raw.githubusercontent.com/frannksz/arch-chroot/main/arch-chroot.sh"
chmod +x arch-chroot.sh
./arch-chroot.sh
```


##### OBS:

Se quiser pode remover o script após de tudo instalado:

```bash
sudo rm -rf /arch-chroot.sh
```

Caso não queira remover, pode deixa-lo onde está, não afeta nada no uso.


### Contatos:

[Email](mailto:fraank@riseup.net)
