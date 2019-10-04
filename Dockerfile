FROM consul:0.8.1
ADD ./config /config/
RUN apk update && apk add bash
EXPOSE 8300
EXPOSE 8301
EXPOSE 8301
EXPOSE 8302
EXPOSE 8400
EXPOSE 8500
EXPOSE 8600
ENTRYPOINT ["/bin/bash", "-c", "(export JIP=$(wget -qO- 169.254.169.254/latest/meta-data/local-ipv4);export JNODE=$(wget -qO- 169.254.169.254/latest/meta-data/local-hostname);consul agent -client=0.0.0.0 -node=$JNODE -retry-join-ec2-tag-key=$EC2_TAG_KEY -retry-join-ec2-tag-value=$EC2_TAG_VALUE $CONSUL_PARAMS -server -data-dir=/data -advertise=$JIP -config-dir=/config)"]
