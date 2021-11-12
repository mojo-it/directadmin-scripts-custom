#!/bin/bash
#
# this is a script at /root/bin used in an incrontab-config to alter exim-parameters that i need and wont be customiseable otherway in Directadmin
#
# incrontab:
# /etc/exim.conf	IN_MODIFY	    [ ! -e /tmp/da_postbuild-exim.lck ] && /root/bin/da_postbuild-exim.sh
#

doEximquotafix()  { 
    grep -qE ^\\*.*.quota /etc/exim.conf && sed -i -e '/^\\*.*.quota/s/^/#/' /etc/exim.conf
}

doEximlogselector() {
    perl -i -pe 'BEGIN{undef $/;} s/log_selector.*arguments/log_selector = +delivery_size +sender_on_delivery +received_recipients +received_sender +smtp_confirmation +subject +smtp_incomplete_transaction +tls_cipher +tls_peerdn +tls_sni +incoming_port +outgoing_port -dnslist_defer -host_lookup_failed -queue_run -rejected_header -retry_defer -skip_delivery +arguments +outgoing_interface/smg' /etc/exim.conf
    systemctl reload exim
}

##########
doEximaction() {
    touch /tmp/da_postbuild-exim.lck
    sleep 10s
    # fix exim.conf
    doEximquotafix
    doEximlogselector
    systemctl reload exim.service
    rm -f /tmp/da_postbuild-exim.lck
}

if [ ! -e /tmp/da_postbuild-exim.lck ];then
    doEximaction
else
    sleep 15s
    doEximaction
fi
