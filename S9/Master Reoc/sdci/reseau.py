import logging
from mininet.log import setLogLevel
from emuvim.dcemulator.net import DCNetwork
from emuvim.api.rest.rest_api_endpoint import RestApiEndpoint
from emuvim.api.openstack.openstack_api_endpoint import OpenstackApiEndpoint

logging.basicConfig(level=logging.INFO)
setLogLevel('info')  # set Mininet loglevel
logging.getLogger('werkzeug').setLevel(logging.DEBUG)
logging.getLogger('api.openstack.base').setLevel(logging.DEBUG)
logging.getLogger('api.openstack.compute').setLevel(logging.DEBUG)
logging.getLogger('api.openstack.keystone').setLevel(logging.DEBUG)
logging.getLogger('api.openstack.nova').setLevel(logging.DEBUG)
logging.getLogger('api.openstack.neutron').setLevel(logging.DEBUG)
logging.getLogger('api.openstack.heat').setLevel(logging.DEBUG)
logging.getLogger('api.openstack.heat.parser').setLevel(logging.DEBUG)
logging.getLogger('api.openstack.glance').setLevel(logging.DEBUG)
logging.getLogger('api.openstack.helper').setLevel(logging.DEBUG)




def create_topology():
    """
    Topologie : Serveur -> GI -> Zone
    """
    net = DCNetwork(monitor=False, enable_learning=True)

    dc1 = net.addDatacenter("dc1")
    # add OpenStack-like APIs to the emulated DC
    api1 = OpenstackApiEndpoint("0.0.0.0", 6001)
    api1.connect_datacenter(dc1)
    api1.start()
    api1.connect_dc_network(net)
    # add the command line interface endpoint to the emulated DC (REST API)
    rapi1 = RestApiEndpoint("0.0.0.0", 5001)
    rapi1.connectDCNetwork(net)
    rapi1.connectDatacenter(dc1)
    rapi1.start()

    print("*** Création des conteneurs Docker")
    
    serveur = net.addDocker(
        "Serveur",
        ip="10.0.0.5",
        dimage="serveur"
    )
    
    gi = net.addDocker(
        "GI",
        ip="10.0.0.10",
        dimage="gi",
        environment={
            "local_name":"gi"
        }
    )

    zone1 = net.addDocker(
        "Zone1",
        ip="10.0.0.20",
        dimage="zone",
		environment={
        	"local_name": "Zone1",
        	"remote_ip": "10.0.0.10",
        	"remote_name": "GI"
    }
    )
    zone2 = net.addDocker(
        "Zone2",
        ip="10.0.0.30",
        dimage="zone",
		environment={
        	"local_name": "Zone2",
        	"remote_ip": "10.0.0.10",
        	"remote_name": "GI"
    }
    )

    zone3 = net.addDocker(
        "Zone3",
        ip="10.0.0.40",
        dimage="zone",
		environment={
        	"local_name": "Zone3",
        	"remote_ip": "10.0.0.10",
        	"remote_name": "GI"
    }
    )






    print("*** Ajout des switches")
    s1 = net.addSwitch("s1")
    s2 = net.addSwitch("s2")

    print("*** Création des liens")

    net.addLink(serveur, s2)
    net.addLink(gi, s2)
    net.addLink(s1, s2)
    net.addLink(s2, dc1)
    net.addLink(zone1, s1)
    net.addLink(zone2, s1)
    net.addLink(zone3, s1)

    print("*** Démarrage réseau")
    net.start()
    print("*** Démarrage des entrypoint")
    serveur.cmd("/entrypoint.sh &")
    gi.cmd("/entrypoint.sh &")
    zone1.cmd("/entrypoint.sh &")
    zone2.cmd("/entrypoint.sh &")
    zone3.cmd("/entrypoint.sh &")

    print("*** Lancer CLI")
    net.CLI()

    print("*** Arrêt réseau")
    net.stop()




def main():
    create_topology()


if __name__ == '__main__':
    main()
