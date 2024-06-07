# Manual Bootstrapping of PKI for OpenZiti using OpenSSL

My main objective in bootstrapping and utilizing OpenZiti is to achieve security at the application level. I wanted to try something new beyond the classic VPNs available today, such as ZeroTier, Tailscale, Endpoint Security, or Fortinet VPN. In many organizations I have worked with, these VPN solutions seemed half-baked. It always felt strange when my connectivity allowed me to reach highly sensitive systems like ESB or DWH. Of course, I shouldn't have had access to these systems, but I did. This meant that a potential intruder could have had access too! Hence, my search led me to the great find of OpenZiti.

I struggled to understand OpenZiti for quite some time because it was a new field for me (ZeroTrust). The PKI in OpenZiti, in particular, looked daunting and complicated. The tutorial didn't help much as it used the Ziti sub-app to create the entire PKI, which was not transparent to me as a learner. However, the OpenZiti Forum helped a lot in understanding how PKI works in conjunction with the fabric. I started a few topics that you can find here [1] [2] [3].

From these discussions, I understood one vital thing: if I had not created the entire PKI manually, it would have been hard to know exactly how everything works together.

So, I started by making a few assumptions:

1. There is an organization that already has a bootstrapped PKI, and the root CA of the organization is already distributed.
2. The private key for the root CA is stored on an HSM module (or any trusted intermediary, in essence).
3. The controller node could be compromised, and the PKI should be able to recover from this.

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

---

Video from OpenZiti and the host Clint going step-by-step:

[![OpenZiti](https://img.youtube.com/vi/X_bvaZOAh34/0.jpg)](https://www.youtube.com/watch?v=X_bvaZOAh34)
