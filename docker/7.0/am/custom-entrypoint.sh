#!/bin/bash

#
# Copyright 2019-2020 ForgeRock AS. All Rights Reserved
#


am-crypto() {
    java -jar /home/forgerock/crypto-tool.jar $@
}

# Additiomal place holder
export AM_PROMETHEUS_PASSWORD_ENCRYPTED=$( echo -n "${AM_PROMETHEUS_PASSWORD:-prometheus}" | am-crypto encrypt des )


# These need to base64 encoded for now. When the secret gen is finished, remove these
export AM_AUTHENTICATION_SHARED_SECRET=$(echo -n "$AM_AUTHENTICATION_SHARED_SECRET" | base64)
export AM_SESSION_STATELESS_SIGNING_KEY=$(echo -n "$AM_SESSION_STATELESS_SIGNING_KEY" | base64)
export AM_SESSION_STATELESS_ENCRYPTION_KEY=$(echo -n "$AM_SESSION_STATELESS_ENCRYPTION_KEY" | base64)
export AM_SELFSERVICE_LEGACY_CONFIRMATION_EMAIL_LINK_SIGNING_KEY=$(echo -n "$AM_SELFSERVICE_LEGACY_CONFIRMATION_EMAIL_LINK_SIGNING_KEY" | base64)


exec /home/forgerock/docker-entrypoint.sh