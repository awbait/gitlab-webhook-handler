server {
	listen 80;

	server_name $branch.example.ru;

	index index.php;

	# access_log /var/log/nginx/$branch.example.ru_access.log;
	# error_log /var/log/nginx/$branch.example.ru_error.log;

	set $root_path /var/www/ci_build/$branch;
	root $root_path;

	set $php_sock unix:/run/php-fpm-test.example.ru.socket;

	client_max_body_size 1024M;
	client_body_buffer_size 4M;

	location = / {
		fastcgi_pass    $php_sock;
		fastcgi_param SCRIPT_FILENAME $document_root/index.php;
		include fastcgi_params;
		fastcgi_read_timeout 600;

		fastcgi_cache fastcgi;
               fastcgi_cache_key "$host|$uri";
               fastcgi_cache_valid 10s;
           #    fastcgi_hide_header "Set-Cookie";
           #    fastcgi_ignore_headers Expires Cache-Control Set-Cookie;
           #    fastcgi_cache_bypass $http_cookie $arg_repidchanged;
           #    fastcgi_no_cache $http_cookie $arg_repidchanged;
	}
	location = /index.php {
		return 301 /$is_args$args;
	}

	location /catalog/ {

if ($request_uri ~ "^(.*)index\.(?:php|html)") {
                return 301 $1; }

		try_files $uri/index.php /bitrix/urlrewrite.php?$args;
		fastcgi_pass    $php_sock;
		include fastcgi_params;
		fastcgi_index index.php;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		fastcgi_read_timeout 600;

		fastcgi_cache fastcgi;
               fastcgi_cache_key "$host|$request_uri";
               fastcgi_cache_valid 10s;
           #    fastcgi_hide_header "Set-Cookie";
           #    fastcgi_ignore_headers Expires Cache-Control Set-Cookie;
           #    fastcgi_cache_bypass $http_cookie $arg_repidchanged;
           #    fastcgi_no_cache $http_cookie $arg_repidchanged;
	}

	location = /market/api/dev/samara/cart {
		try_files       $uri @bitrix;
	}

	location / {
		try_files       $uri $uri/ @bitrix;
	}

	location ~* /upload/.*\.(php|php3|php4|php5|php6|phtml|pl|asp|aspx|cgi|dll|exe|shtm|shtml|fcg|fcgi|fpl|asmx|pht|py|psp|rb|var)$ {
		types {
			application/octet-stream text/plain php php3 php4 php5 php6 phtml pl asp aspx cgi dll exe ico shtm shtml fcg fcgi fpl asmx pht py psp rb var;
		}
	}

	location ~ \.php$ {
		location ~ ^/bitrix/(?:catalog_export/|tmp/) {
			deny all;
		}
		location ~ ^/(?:comp_map/query-count-logs|images)/ {
			deny all;
		}
		try_files       $uri @bitrix;
		fastcgi_pass    $php_sock;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		include fastcgi_params;
		fastcgi_read_timeout 600;
	}
	location @bitrix {
		fastcgi_pass    $php_sock;
		include fastcgi_params;
		fastcgi_param SCRIPT_FILENAME $document_root/bitrix/urlrewrite.php;
		fastcgi_read_timeout 600;
	}
	location ~* /bitrix/admin.+\.php$ {
		try_files       $uri @bitrixadm;
		fastcgi_pass    $php_sock;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		include fastcgi_params;
		fastcgi_read_timeout 600;
	}
	location @bitrixadm{
		fastcgi_pass    $php_sock;
		include fastcgi_params;
		fastcgi_param SCRIPT_FILENAME $document_root/bitrix/admin/404.php;
		fastcgi_read_timeout 600;
	}

	location = /favicon.ico {
		log_not_found off;
		access_log off;
	}

	location = /robots.txt {
		allow all;
		log_not_found off;
		access_log off;
	}

	#
	# block this locations for any installation
	#

	# ht(passwd|access)
	location ~* /\.ht  { deny all; }

	# repositories
	location ~* /\.(svn|hg|git) { deny all; }

	# bitrix internal locations
	location ~* ^/bitrix/(modules|local_cache|stack_cache|managed_cache|php_interface) {
		deny all;
	}

	# upload files
	location ~* ^/upload/1c_[^/]+/ { deny all; }

	# use the file system to access files outside the site (cache)
	location ~* /\.\./ { deny all; }
	location ~* ^/bitrix/html_pages/\.config\.php { deny all; }
	location ~* ^/bitrix/html_pages/\.enabled { deny all; }

	# Intenal locations
	location ^~ /upload/support/not_image   { internal; }

	# Cache location: composite and general site
	location ~* @.*\.html$ {
		internal;
		# disable browser cache, php manage file
		expires -1;
		add_header X-Bitrix-Composite "Nginx (file)";
	}

	# Player options, disable no-sniff
	location /bitrix/components/bitrix/player/mediaplayer/player {
		add_header Access-Control-Allow-Origin *;
	}

	# Accept access for merged css and js
	location ~* ^/bitrix/cache/(css/.+\.css|js/.+\.js)$ {
		expires 30d;
		log_not_found off;
		error_page 404 /404.php;
	}

	# Disable access for other assets in cache location
	location /bitrix/cache              { deny all; }

	location ~* ^/(upload|bitrix/images|bitrix/tmp) {
		expires 30d;
		log_not_found off;
	}

	location  ~* \.(css|js|gif|png|jpg|jpeg|ico|ogg|ttf|woff|eot|otf)$ {
		error_page 404 /404.php;
		expires 30d;
		log_not_found off;
	}

	location ^~ /logs/ {
		deny all;
	}
	
	location ^~ /sync_uploads/ {
		deny all;
	}
}
