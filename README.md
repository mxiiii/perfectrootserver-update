#The perfect rootserver update
by Shoujii
https://github.com/shoujii/perfectrootserver-update/

Based on https://github.com/zypr/perfectrootserver & https://github.com/mxiiii/perfect_update
Thanks to Zypr and and mxiiii
Compatible with Debian 8.x (jessie)

#Important:
The Script will delete the rm /root/backup/ folder!!!

#Short instructions:

[Get the latest release](https://github.com/shoujii/perfectrootserver-update/releases "Latest Release"):
```
wget -O ~/perfectrootserver-update.tar.gz https://github.com/shoujii/perfectrootserver-update/archive/1.2.2.tar.gz
```

Extract:
```
tar -xzf ~/perfectrootserver-update.tar.gz -C ~/ --strip-components=1
```

Edit settings to your needs:
```
nano ~/updateconfig.cfg
```

Start the installation script:
```
bash ~/update.sh
```

Follow the instructions! 
