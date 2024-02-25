{ config, pkgs, ... }:

{

	# Allow firmware even with license
	hardware.enableRedistributableFirmware = true;
	hardware.enableAllFirmware = true;

}