{ config, pkgs, ... }:

{

    boot.kernel.sysctl = {

    # Enable MTU probing, as SteamOS does
    # See: https://github.com/ValveSoftware/SteamOS/issues/1006
    # See also: https://www.reddit.com/r/SteamDeck/comments/ymqvbz/ubisoft_connect_connection_lost_stuck/j36kk4w/?context=3
    "net.ipv4.tcp_mtu_probing" = true;

    # Helps with performance in proton, see https://archlinux.org/news/increasing-the-default-vmmax_map_count-value/
    "vm.max_map_count" = 2147483642;

    # Taken from steamos-customizations-jupiter package on the Steam Deck
    # 20-shed.conf
    "kernel.sched_cfs_bandwidth_slice_us" = 3000;
    "kernel.sched_latency_ns" = 3000000;
    "kernel.sched_min_granularity_ns" = 300000;
    "kernel.sched_wakeup_granularity_ns" = 500000;
    "kernel.sched_migration_cost_ns" = 50000;
    "kernel.sched_nr_migrate" = 128;

    # 20-net-timeout.conf
    # This is required due to some games being unable to reuse their TCP ports
    # if they're killed and restarted quickly - the default timeout is too large.
    "net.ipv4.tcp_fin_timeout" = 5;

    powerManagement.cpuFreqGovernor = "performance";
  };
}