require_relative '../lib/credentials'

workers Integer(ENV.fetch('WEB_CONCURRENCY', 2))
threads_count = Integer(ENV.fetch('MAX_THREADS', 5))
threads threads_count, threads_count

preload_app!

port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  Credentials.redis.quit if Credentials.redis?
end
