#!/bin/sh

function die()
{
    echo $1
    exit 1
}

BASEDIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

echo "> Install Redis"

yum install -y gcc
curl -O http://download.redis.io/releases/redis-3.2.8.tar.gz
tar xzf redis-3.2.8.tar.gz
cd redis-3.2.8/deps
make geohash-int hiredis jemalloc linenoise lua
cd ..
make
make install

# Just use default settings to install service
utils/install_server.sh <<EOF





EOF

# Change default password
sed -i "s/# requirepass foobared/requirepass yourpassword/g" /etc/redis/6379.conf
/etc/init.d/redis_6379 restart

function clone()
{
    touch /var/log/redis_$1.log
    mkdir -p /var/lib/redis/$1

    cp /etc/redis/6379.conf /etc/redis/redis_$1.conf

    sed -i "s#6379#$1#g" /etc/redis/redis_$1.conf

    cp /etc/init.d/redis_6379 /etc/init.d/redis_$1
    sed -i "s#/etc/redis/6379.conf#/etc/redis/redis_$1.conf#g" /etc/init.d/redis_$1
    sed -i "s#6379#$1#g" /etc/init.d/redis_$1

    chkconfig --add redis_$1 && echo "Successfully added redis_$1 to chkconfig"
    chkconfig --level 345 redis_$1 on && echo "Successfully added redis_$1 to runlevels 345"

    /etc/init.d/redis_$1 start || die "Failed starting redis_$1 service..."
}

clone 6380
clone 6381
