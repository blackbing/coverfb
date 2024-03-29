# Minimal sample configuration file for Unicorn (not Rack) when used
# with daemonization (unicorn -D) started in your working directory.
#
# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.
# See also http://unicorn.bogomips.org/examples/unicorn.conf.rb for
# a more verbose configuration using more features.

listen 3003 # by default Unicorn listens on port 8080
worker_processes 2 # this should be >= nr_cpus
pid "tmp/pids/unicorn.pid"
# stderr_path "log/unicorn-error.log"
# stdout_path "log/unicorn.log"
