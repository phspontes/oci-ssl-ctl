#/bin/bash

if [ -z $1 ]; then
        echo -e "\nUsage: $0 [CERT_CONFIG_FILE]\n";
        exit 1;
fi

SCRIPT_DIR=`dirname $0`

if [ -f $SCRIPT_DIR/config/cert_"$1".conf ]; then
        source $SCRIPT_DIR/config/cert_"$1".conf
        else
        echo -e "\nConfig file $SCRIPT_DIR/config/cert_$1.conf not found! Please create it based on the cert_template.conf file and run the script again.\n"
        exit 1;
fi

source $SCRIPT_DIR/config/global.ini || exit 1;

DATE=`date +%Y%m%d-%H%M`

#---------------------- Functions -----------------------#

#------------------ CertBot + Multi DNS -----------------#

fn_certbot_create_cert () {

        if [ ! -z $CERT_SAN ]; then
                CERTBOT_OPTS=$CERTBOT_OPTS" -d $CERT_SAN"
        fi
        
	$CERTBOT_BIN_OCI certonly --email $LETS_MAIL_ADMIN \
                                --authenticator dns-multi \
				--dns-multi-credentials="$SCRIPT_DIR/.oci/$DNS_SERVICE-dns-multi.ini" \
                                -d $CERT_NAME \
                                --dns-multi-propagation-seconds 90 \
                                $CERTBOT_OPTS \
                                --post-hook "touch $SCRIPT_DIR/temp/$CERT_NAME.DO_UPDATE"
	
	fn_certbot_create_cert_status=$?

	if [ $fn_certbot_create_cert_status -ne 0 ]; then exit $fn_certbot_create_cert_status ; fi

	return $fn_certbot_create_cert_status

}

fn_certbot_renew_cert () {
        
	$CERTBOT_BIN_OCI  renew --cert-name $CERT_NAME \
                                --authenticator dns-multi \
                                --dns-multi-credentials="$SCRIPT_DIR/.oci/$DNS_SERVICE-dns-multi.ini" \
                                --dns-multi-propagation-seconds 90 \
                                $CERTBOT_OPTS \
                                --post-hook "touch $SCRIPT_DIR/temp/$CERT_NAME.DO_UPDATE"
	
	fn_certbot_renew_cert_status=$?
	
	if [ $fn_certbot_renew_cert_status -ne 0 ]; then exit $fn_certbot_renew_cert_status ; fi

	return $fn_certbot_renew_cert_status

}

#--------------------- Utils ----------------------------#

fn_convert_pem_to_string () {

        # PEM to String
        CERT=`awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' $CERT_DIR/cert.pem`
        CHAIN=`awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' $CERT_DIR/chain.pem`
        KEY=`awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' $CERT_DIR/privkey.pem`

}

#---------------- OCI Certificates Manager --------------#

fn_cert_mngr_create_cert () {

        fn_convert_pem_to_string

        $OCI_CLI_BIN certs-mgmt certificate create-by-importing-config --config-file $OCI_CLI_CONFIG_FILE \
                                --name $CM_CERT_NAME \
                                --compartment-id $CM_CERT_COMPARTMENT_ID \
                                --cert-chain-pem "$CHAIN" \
                                --certificate-pem "$CERT" \
                                --private-key-pem "$KEY" \
                                --version-name $DATE \
                                --wait-for-state ACTIVE

        fn_cert_mngr_create_cert_status=$?

	return $fn_cert_mngr_create_cert_status

}

fn_cert_mngr_import_cert () {

        CERT_ID=`$OCI_CLI_BIN search resource structured-search --config-file $OCI_CLI_CONFIG_FILE \
                --query-text "query certificate resources where displayName = \"$CM_CERT_NAME\"" \
                --query 'data.items[*].identifier' | grep 'oci' | xargs `

        if [ -z $CERT_ID ]; then
                echo $CM_CERT_NAME não existe!
                fn_cert_mngr_create_cert
                else

        fn_convert_pem_to_string

        if [ $CM_CERT_HOT_UPDATE = "true" ]; then
                CM_CERT_UPDATE_STATE="CURRENT"
                else
                CM_CERT_UPDATE_STATE="PENDING"
        fi

        $OCI_CLI_BIN certs-mgmt certificate update-certificate-by-importing-config-details --config-file $OCI_CLI_CONFIG_FILE \
                                --certificate-id $CERT_ID \
                                --cert-chain-pem "$CHAIN" \
                                --certificate-pem "$CERT" \
                                --private-key-pem "$KEY" \
                                --version-name $DATE \
                                --stage $CM_CERT_UPDATE_STATE \
                                --wait-for-state ACTIVE

        fn_cert_mngr_import_cert_status=$?
	
	return $fn_cert_mngr_import_cert_status
	
        fi

}

#--------------------- Main Function --------------------#

main () {

if [ -d $CERT_DIR ]; 
		then
                	fn_certbot_renew_cert
        	else
                	fn_certbot_create_cert
fi

for CTL_FILE in `ls $SCRIPT_DIR/temp/*.DO_UPDATE 2> /dev/null`; do

        fn_cert_mngr_import_cert
        
	if [ $? = "0" ] ; then
                mv $CTL_FILE $CTL_FILE"_"$DATE"_SUCESS"
                else
                mv $CTL_FILE $CTL_FILE"_"$DATE"_FAIL"
                exit 4;
        fi

done

}

#----------------------- Execution ----------------------#

main | tee -a $SCRIPT_DIR/logs/$CERT_NAME"_"$DATE.log
