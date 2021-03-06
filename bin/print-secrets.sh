#!/bin/bash

getsec () {
    kubectl get secret $1 -o jsonpath="{.data.$2}" | base64 --decode
}

amadmin_password () {
    echo "$(getsec amster-env-secrets AMADMIN_PASS) (amadmin user)" 
}

profile_passwords () {
    echo ""
}

openidm_admin_password () {
    echo "$(getsec idm-env-secrets OPENIDM_ADMIN_PASSWORD) (openidm-admin user)" 
}

6.5_directory_manager_password () {
    echo "$(getsec ds dirmanager\\.pw) (cn=Directory Manager user)"
}

7.0_directory_manager_password () {
    echo "$(getsec ds-passwords dirmanager\\.pw) (uid=admin user)"
}

setup_profile_service_account_passwords () {
    [ $1 == "cfg" ] || [ $1 == "all" ] && echo "$(getsec amster-env-secrets CFGUSR_PASS) (Configuration store service account (uid=am-config,ou=admins,ou=am-config))"
    [ $1 == "cts" ] || [ $1 == "all" ] && echo "$(getsec amster-env-secrets CTSUSR_PASS) (CTS profile service account (uid=openam_cts,ou=admins,ou=famrecords,ou=openam-session,ou=tokens))"
    [ $1 == "usr" ] || [ $1 == "all" ] && echo "$(getsec amster-env-secrets USRUSR_PASS) (Identity repository service account (uid=am-identity-bind-account,ou=admins,ou=identities))"
}

backup_restore_info () {
    echo ""
    echo "To back up all the generated secrets:"
    echo ""
    echo "  kubectl get secret -lsecrettype=forgeops-generated -o yaml > secrets.yaml"
    echo ""
    echo "To restore the backed up secrets:"
    echo ""
    echo "  kubectl apply -f secrets.yaml"
    echo ""
}

# Get major version by presence of ds-env-secrets secret.
get_version () {
    if ( secret=$(kubectl get secret ds-env-secrets 2>/dev/null) ); then
        version="7.0"
    else
        version="6.5"
    fi
}

get_version

# Either get individual passwords or display all passwords if no args provided.
if [[ "$#" > 0 ]]; then
    # Individual passwords
    case $1 in 
            "amadmin")
                amadmin_password | head -n 1 | awk '{print $1;}'
            ;;

            "idmadmin")
                [[ "$version" == "7.0" ]] && echo "No IDM admin password for version 7.0"
                [[ "$version" == "6.5" ]] && openidm_admin_password | head -n 1 | awk '{print $1;}'
            ;;

            "dsadmin")
                [[ "$version" == "7.0" ]] && 7.0_directory_manager_password | head -n 1 | awk '{print $1;}'
                [[ "$version" == "6.5" ]] && 6.5_directory_manager_password | head -n 1 | awk '{print $1;}'
            ;;

            "dscfg")
                setup_profile_service_account_passwords cfg | head -n 1 | awk '{print $1;}'
            ;;

            "dscts")
                setup_profile_service_account_passwords cts | head -n 1 | awk '{print $1;}'
            ;;

            "dsusr")
                setup_profile_service_account_passwords usr | head -n 1 | awk '{print $1;}'
            ;;

            *)
                printf "\nNOTE: Incorrect argument. Please provide the following arguments: \n"
                echo "./printSecrets.sh amadmin  - amadmin user"
                if [ $version == "6.5" ]; then
                    echo "./printSecrets.sh idmadmin - idmadmin user (6.5 only)" 
                    echo "./printSecrets.sh dsadmin  - cn=Directory Manager user"
                else
                    echo "./printSecrets.sh dsadmin  - uid=admin user"
                fi
                echo "./printSecrets.sh dscfg    - Config store service account (uid=am-config,ou=admins,ou=am-config)"
                echo "./printSecrets.sh dscts    - CTS profile service account (uid=openam_cts,ou=admins,ou=famrecords,ou=openam-session,ou=tokens)"
                echo "./printSecrets.sh dsusr    - Identity repository service account (uid=am-identity-bind-account,ou=admins,ou=identities)"
                exit 1;
            ;;
    esac
else
    # All passwords
    case $version in 
        "6.5")
            echo ""  
            echo "Administrator passwords:"
            echo ""  
            amadmin_password
            openidm_admin_password
            6.5_directory_manager_password
            echo ""
            echo "Passwords for service accounts generated by setup profiles:"
            echo ""
            setup_profile_service_account_passwords all
            backup_restore_info
        ;;

        "7.0")
            echo ""  
            echo "Administrator passwords:"
            echo ""  
            amadmin_password
            7.0_directory_manager_password
            echo ""
            echo "Passwords for service accounts generated by setup profiles:"
            echo ""
            setup_profile_service_account_passwords all
            backup_restore_info
        ;;
    esac
fi

