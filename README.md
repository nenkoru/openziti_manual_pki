# Manual Bootstrapping of PKI for OpenZiti using openssl

My main objective from bootstrapping and utilizing OpenZiti is to have security on the application level.
I wanted to try out something new apart from the classic VPNs that exist nowadays like ZeroTier, Tailscale, Endpoint Security, or Fortinet VPN.
I saw that these solutions of VPNs are half-baked in many organizations I have worked in. It always felt strange when my connectivity
of mine was able to reach quite sensitive systems like ESB or DWH. Of course, I could have hadn't have access to these systems. But I did have a connectivity to them.
This being that a potential intruder could have had it too! Hence the search and a great find of OpenZiti.

I have struggled to understand OpenZiti for quite some time because it was a new field for me(ZeroTrust).
Especially the PKI the OpenZiti looked daunting and complicated.
The tutorial didn't help much as it uses the Ziti sub-app to create the whole PKI which was not transparent to me as a learner.
This has helped a lot in understanding how PKI works in conjunction with how the fabric works on the OpenZiti Forum.
I started a few topics which you can find here[1][2][3].

As well as having those topics I understood one vital thing; if I had not made the whole PKI manually it would have been hard to know how exactly everything works together.

So I started by making a few assumptions:
1) There is an organization that already has a bootstrapped PKI and the root CA of the organization is already distributed
2) The private key for the root CA is stored on an HSM module(or for any trusted intermediary in essence)
3) The controller node could be compromised and the PKI should be able to recover from this

By having these assumptions and this whole backstory I started my journey.

I have made this PKI by thoroughly looking through this[4] forum and two videos[5][6] as well as the from-scratch.sh[7] and this ziti-cli-functions[8] script from the quickstart.

From this point refer to BOOTSTRAP_PKI.md
Also take a look into pki_topology.(png|puml) 

[1] https://openziti.discourse.group/t/general-architecture-questions/2210

[2] https://openziti.discourse.group/t/openziti-network-from-scratch/2168

[3] https://openziti.discourse.group/t/separate-usage-of-a-cas-pkey-from-a-controller-feature-request/2376

[4] https://openziti.discourse.group/t/what-does-the-quickstart-do-that-i-need-to-do-myself/1600

[5] https://www.youtube.com/watch?v=10KUPH-LwlA

[6] https://www.youtube.com/watch?v=m13qkO6lV9g

[7] https://raw.githubusercontent.com/dovholuknf/openziti-compose/main/from-scratch.sh

[8] https://get.openziti.io/ziti-cli-functions.sh
