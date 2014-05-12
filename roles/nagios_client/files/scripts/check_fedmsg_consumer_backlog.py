#!/usr/bin/env python

import json
import os
import socket
import sys
import zmq

try:
    service = sys.argv[1]
    check_consumer = sys.argv[2]
    backlog_warning = int(sys.argv[3])
    backlog_critical = int(sys.argv[4])
    fname = '/var/run/fedmsg/monitoring-%s.socket' % service
    if not os.path.exists(fname):
        print "UNKNOWN - %s does not exist" % fname
        sys.exit(3)
    connect_to = "ipc:///%s" % fname
    ctx = zmq.Context()
    s = ctx.socket(zmq.SUB)
    s.connect(connect_to)
    s.setsockopt(zmq.SUBSCRIBE, '')
    msg = s.recv()
    msg = json.loads(msg)

    for consumer in msg['consumers']:
        if consumer['name'] == check_consumer:
            if consumer['backlog'] is None:
                print 'ERROR: fedmsg consumer %s is not initialized' % consumer['name']
                sys.exit(3)
            elif consumer['backlog'] > backlog_critical:
                print 'CRITICAL: fedmsg consumer %s backlog value is %i' % (consumer['name'],consumer['backlog'])
                sys.exit(2)
            elif consumer['backlog'] > backlog_warning:
                print 'WARNING: fedmsg consumer %s backlog value is %i' % (consumer['name'],consumer['backlog'])
                sys.exit(1)
            else:
                print 'OK: fedmsg consumer %s backlog value is %i' % (consumer['name'],consumer['backlog'])
                sys.exit(0)

except Exception as err:
    print "UNKNOWN:", str(err)
    sys.exit(3)
