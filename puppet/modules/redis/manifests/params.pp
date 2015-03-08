# Class: redis::params
#
#
class redis::params {
  # TODO: refactor this var to a common module and make other module use it
	$os_suffix = $operatingsystem ? {
		/(?i)(Debian|Ubuntu)/ => 'debian',
		/(?i)(RedHat|CentOS)/ => 'redhat',
	}
	
  $version = $redis_version ? {
    ''      => '2.2.12',
    default => $redis_version,
  }
  
  $libdir = $redis_libdir ? {
    ''      => '/var/lib/redis',
    default => $redis_libdir,
  }
  
	$logdir = $redis_logdir ? {
	 ''      => '/var/log/redis',
	 default => $redis_logdir,
	}
	
	$configfile = $redis_configfile ? {
	 ''      => '/etc/redis.conf',
	 default => $redis_configfile,
	}
	
	$user = $redis_user ? {
	 ''     => 'redis',
	 default => $redis_user,
	}
	
	# Configuration parameters for redis.conf
	
	# By default Redis will be configured to run as a daemon. Use 'no' if you don't want to.
  # Note that Redis will write a pid file in the location specified by
  # $redis_pidfile (/var/run/redis.pid by default) when daemonized.
	$daemonize = $redis_daemonize ? {
	 'yes'   => 'yes',
	 'no'    => 'no',
	 default => 'yes',
	}
	
	# When run as a daemon, Redis write a pid file in /var/run/redis.pid by default.
  # You can specify a custom pid file location here.
	$pidfile = $redis_pidfile ? {
	 ''      => '/var/run/redis.pid',
	 default => $redis_pidfile,
	}
	
	# Accept connections on the specified port, default is 6379
	$port = $redis_port ? {
	 ''      => '6379',
	 default => $redis_port,
	}
	
	# If you want to bind redis to a single interface, specify one here.
	# If an interface is not specified (the default) the bind option is not
  # used and all the interfaces will listen for connections.
	$interface = $redis_interface ? {
		''      => false,
		default => $redis_interface,
	}
	if $interface {
	  $bind_address = inline_template("<%= scope.lookupvar('ipaddress_' + interface) %>")
	}
	
	# Close the connection after a client is idle for N seconds (0 to disable)
	$timeout = $redis_timeout ? {
	 ''      => '300',
	 default => $redis_timeout,
	}
	
	# Set server logging verbosity. It can be one of:
  # debug (a lot of information, useful for development/testing)
  # verbose (many rarely useful info, but not a mess like the debug level)
  # notice (moderately verbose, what you want in production probably)
  # warning (only very important / critical messages are logged)
  $loglevel = $redis_loglevel ? {
    'debug'   => 'debug',
    'verbose' => 'verbose',
    'notice'  => 'notice',
    'warning' => 'warning',
    default   => 'notice',
  }
  
  # Set the number of databases. The default database is DB 0, you can select
  # a different one on a per-connection basis using SELECT <dbid> where
  # dbid is a number between 0 and 'databases'-1
  $databases = $redis_databases ? {
    ''      => '16',
    default => $redis_databases,
  }
  
  ############################### SNAPSHOTTING  #################################
  #
  # Save the DB on disk:
  #
  #   save <seconds> <changes>
  #
  #   Will save the DB if both the given number of seconds and the given
  #   number of write operations against the DB occurred.
  #
  #   In the example below the behaviour will be to save:
  #   after 900 sec (15 min) if at least 1 key changed
  #   after 300 sec (5 min) if at least 10 keys changed
  #   after 60 sec if at least 10000 keys changed
  #
  #   Note: you can disable saving at all commenting all the "save" lines.
  $save = $redis_save ? {
    ''      => [ '900 1', '300 10','60 10000' ],
    'false' => false,
    default => split($redis_save, ','),
  }
  
  # Compress string objects using LZF when dump .rdb databases?
  # For default that's set to 'yes' as it's almost always a win.
  # If you want to save some CPU in the saving child set it to 'no' but
  # the dataset will likely be bigger if you have compressible values or keys.
  $rdbcompression = $redis_rdbcompression ? {
    'yes'   => 'yes',
    'no'    => 'no',
    default => 'yes',
  }
  
  # The filename where to dump the DB
  $dbfilename = $redis_dbfilename ? {
    ''      => 'dump.rdb',
    default => $redis_dbfilename,
  }
  
  ################################# REPLICATION #################################
  #
  # Master-Slave replication. Specify master_ip to make this Redis instance a copy of
  # another Redis server. Note that the configuration is local to the slave
  # so for example it is possible to configure the slave to save the DB with a
  # different interval, or to listen to another port, and so on.
  $master_ip = $redis_master_ip ? {
    ''      => false,
    default => $redis_master_ip,
  }
  
  $master_port = $redis_master_port ? {
    ''      => $port,
    default => $redis_master_port,
  }
  
  # If the master is password protected (using the "requirepass" configuration
  # directive) it is possible to tell the slave to authenticate before
  # starting the replication synchronization process, otherwise the master will
  # refuse the slave request.
  $master_password = $redis_master_password ? {
    ''      => false,
    default => $redis_master_password,
  }
  
  ################################## SECURITY ###################################
  #
  # Require clients to issue AUTH <PASSWORD> before processing any other
  # commands.  This might be useful in environments in which you do not trust
  # others with access to the host running redis-server.
  #
  # This should stay commented out for backward compatibility and because most
  # people do not need auth (e.g. they run their own servers).
  $requirepass = $redis_requirepass ? {
    ''      => false,
    default => $redis_requirepass,
  }
  
  ################################### LIMITS ####################################
  #
  # Set the max number of connected clients at the same time. By default there
  # is no limit, and it's up to the number of file descriptors the Redis process
  # is able to open. The special value '0' means no limits.
  # Once the limit is reached Redis will close all the new connections sending
  # an error 'max number of clients reached'.
  $maxclients = $redis_maxclients ? {
    ''      => false,
    default => $redis_maxclients,
  }
  
  # Don't use more memory than the specified amount of bytes.
  # When the memory limit is reached Redis will try to remove keys with an
  # EXPIRE set. It will try to start freeing keys that are going to expire
  # in little time and preserve keys with a longer time to live.
  # Redis will also try to remove objects from free lists if possible.
  #
  # If all this fails, Redis will start to reply with errors to commands
  # that will use more memory, like SET, LPUSH, and so on, and will continue
  # to reply to most read-only commands like GET.
  #
  # WARNING: maxmemory can be a good idea mainly if you want to use Redis as a
  # 'state' server or cache, not as a real DB. When Redis is used as a real
  # database the memory usage will grow over the weeks, it will be obvious if
  # it is going to use too much memory in the long run, and you'll have the time
  # to upgrade. With maxmemory after the limit is reached you'll start to get
  # errors for write operations, and this may even lead to DB inconsistency.
  $maxmemory = $redis_maxmemory ? {
    ''      => false,
    default => $redis_maxmemory,
  }
  
  # This new configuration option is used to specify the algorithm (policy) to use when we need to reclaim memory. There are five different algorithms now:
  # 
  #     volatile-lru remove a key among the ones with an expire set, trying to remove keys not recently used.
  #     volatile-ttl remove a key among the ones with an expire set, trying to remove keys with short remaining time to live.
  #     volatile-random remove a random key among the ones with an expire set.
  #     allkeys-lru like volatile-lru, but will remove every kind of key, both normal keys or keys with an expire set.
  #     allkeys-random like volatile-random, but will remove every kind of keys, both normal keys and keys with an expire set.
  $maxmemory_policy  = $redis_maxmemory_policy ? {
    'volatile-lru'    => 'volatile-lru',
    'volatile-ttl'    => 'volatile-ttl',
    'volatile-random' => 'volatile-random',
    'allkeys-lru'     => 'allkeys-lru',
    'allkeys-random'  => 'allkeys-random',
    default           => 'volatile-lru',
  }
  
  ############################## APPEND ONLY MODE ###############################
  #
  # By default Redis asynchronously dumps the dataset on disk. If you can live
  # with the idea that the latest records will be lost if something like a crash
  # happens this is the preferred way to run Redis. If instead you care a lot
  # about your data and don't want to that a single record can get lost you should
  # enable the append only mode: when this mode is enabled Redis will append
  # every write operation received in the file appendonly.aof. This file will
  # be read on startup in order to rebuild the full dataset in memory.
  #
  # Note that you can have both the async dumps and the append only file if you
  # like (you have to comment the "save" statements above to disable the dumps).
  # Still if append only mode is enabled Redis will load the data from the
  # log file at startup ignoring the dump.rdb file.
  #
  # The name of the append only file is "appendonly.aof"
  #
  # IMPORTANT: Check the BGREWRITEAOF to check how to rewrite the append
  # log file in background when it gets too big.
  $appendonly = $redis_appendonly ? {
    'yes'   => 'yes',
    'no'    => 'no',
    default => 'no',
  }
  
  # The fsync() call tells the Operating System to actually write data on disk
  # instead to wait for more data in the output buffer. Some OS will really flush
  # data on disk, some other OS will just try to do it ASAP.
  #
  # Redis supports three different modes:
  #
  # no: don't fsync, just let the OS flush the data when it wants. Faster.
  # always: fsync after every write to the append only log . Slow, Safest.
  # everysec: fsync only if one second passed since the last fsync. Compromise.
  #
  # The default is "everysec" that's usually the right compromise between
  # speed and data safety. It's up to you to understand if you can relax this to
  # "no" that will will let the operating system flush the output buffer when
  # it wants, for better performances (but if you can live with the idea of
  # some data loss consider the default persistence mode that's snapshotting),
  # or on the contrary, use "always" that's very slow but a bit safer than
  # everysec.
  #
  # If unsure, use "everysec".
  $appendfsync = $redis_appendfsync ? {
    'always'   => 'always',
    'everysec' => 'everysec',
    'no'       => 'no',
    default    => 'everysec',
  }
  
  ################################ VIRTUAL MEMORY ###############################
  #
  # Virtual Memory allows Redis to work with datasets bigger than the actual
  # amount of RAM needed to hold the whole dataset in memory.
  # In order to do so very used keys are taken in memory while the other keys
  # are swapped into a swap file, similarly to what operating systems do
  # with memory pages.
  #
  # To enable VM just set 'vm-enabled' to yes, and set the following three
  # VM parameters accordingly to your needs.
  $vm_enabled = $redis_vm_enabled ? {
    'yes'   => 'yes',
    'no'    => 'no',
    default => 'no',
  }
  
  # This is the path of the Redis swap file. As you can guess, swap files
  # can't be shared by different Redis instances, so make sure to use a swap
  # file for every redis process you are running.
  #
  # The swap file name may contain "%p" that is substituted with the PID of
  # the Redis process, so the default name /tmp/redis-%p.vm will work even
  # with multiple instances as Redis will use, for example, redis-811.vm
  # for one instance and redis-593.vm for another one.
  #
  # Useless to say, the best kind of disk for a Redis swap file (that's accessed
  # at random) is a Solid State Disk (SSD).
  #
  # *** WARNING *** if you are using a shared hosting the default of putting
  # the swap file under /tmp is not secure. Create a dir with access granted
  # only to Redis user and configure Redis to create the swap file there.
  $vm_swap_file = $redis_vm_swap_file ? {
    ''      => '/tmp/redis-%p.vm',
    default => $redis_vm_swap_file,
  }
  
  # vm-max-memory configures the VM to use at max the specified amount of
  # RAM. Everything that deos not fit will be swapped on disk *if* possible, that
  # is, if there is still enough contiguous space in the swap file.
  #
  # With vm-max-memory 0 the system will swap everything it can. Not a good
  # default, just specify the max amount of RAM you can in bytes, but it's
  # better to leave some margin. For instance specify an amount of RAM
  # that's more or less between 60 and 80% of your free RAM.
  $vm_max_memory = $redis_vm_max_memory ? {
    ''      => '0',
    default => $redis_vm_max_memory,
  }
  
  # Redis swap files is split into pages. An object can be saved using multiple
  # contiguous pages, but pages can't be shared between different objects.
  # So if your page is too big, small objects swapped out on disk will waste
  # a lot of space. If you page is too small, there is less space in the swap
  # file (assuming you configured the same number of total swap file pages).
  #
  # If you use a lot of small objects, use a page size of 64 or 32 bytes.
  # If you use a lot of big objects, use a bigger page size.
  # If unsure, use the default :)
  $vm_page_size = $redis_vm_page_size ? {
    ''      => '32',
    default => $redis_vm_page_size,
  }
  
  # Number of total memory pages in the swap file.
  # Given that the page table (a bitmap of free/used pages) is taken in memory,
  # every 8 pages on disk will consume 1 byte of RAM.
  #
  # The total swap size is vm-page-size * vm-pages
  #
  # With the default of 32-bytes memory pages and 134217728 pages Redis will
  # use a 4 GB swap file, that will use 16 MB of RAM for the page table.
  #
  # It's better to use the smallest acceptable value for your application,
  # but the default is large in order to work in most conditions.
  $vm_pages = $redis_vm_pages ? {
    ''      => '134217728',
    default => $redis_vm_pages,
  }
  
  # Max number of VM I/O threads running at the same time.
  # This threads are used to read/write data from/to swap file, since they
  # also encode and decode objects from disk to memory or the reverse, a bigger
  # number of threads can help with big objects even if they can't help with
  # I/O itself as the physical device may not be able to couple with many
  # reads/writes operations at the same time.
  #
  # The special value of 0 turn off threaded I/O and enables the blocking
  # Virtual Memory implementation.
  $vm_max_threads = $redis_vm_max_threads ? {
    ''      => '4',
    default => $redis_vm_max_threads,
  }
  
  ############################### ADVANCED CONFIG ###############################
  #
  # Glue small output buffers together in order to send small replies in a
  # single TCP packet. Uses a bit more CPU but most of the times it is a win
  # in terms of number of queries per second. Use 'yes' if unsure.
  $glueoutputbuf = $redis_glueoutputbuf ? {
    'yes'   => 'yes',
    'no'    => 'no',
    default => 'yes',
  }
  
  # Hashes are encoded in a special way (much more memory efficient) when they
  # have at max a given numer of elements, and the biggest element does not
  # exceed a given threshold. You can configure this limits with the following
  # configuration directives.
  $hash_max_zipmap_entries = $redis_hash_max_zipmap_entries ? {
    ''      => '64',
    default => $redis_hash_max_zipmap_entries,
  }
  
  $hash_max_zipmap_value = $redis_hash_max_zipmap_value ? {
    ''      => '512',
    default => $redis_hash_max_zipmap_value,
  }
  
  # Active rehashing uses 1 millisecond every 100 milliseconds of CPU time in
  # order to help rehashing the main Redis hash table (the one mapping top-level
  # keys to values). The hash table implementation redis uses (see dict.c)
  # performs a lazy rehashing: the more operation you run into an hash table
  # that is rhashing, the more rehashing "steps" are performed, so if the
  # server is idle the rehashing is never complete and some more memory is used
  # by the hash table.
  #
  # The default is to use this millisecond 10 times every second in order to
  # active rehashing the main dictionaries, freeing memory when possible.
  #
  # If unsure:
  # use "activerehashing no" if you have hard latency requirements and it is
  # not a good thing in your environment that Redis can reply form time to time
  # to queries with 2 milliseconds delay.
  #
  # use "activerehashing yes" if you don't have such hard requirements but
  # want to free memory asap when possible.
  $activerehashing = $redis_activerehashing ? {
    'yes'   => 'yes',
    'no'    => 'no',
    default => 'yes',
  }
}