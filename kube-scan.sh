################################e kubesec-scan.sh ################################

#!/bin/bash

#kubesec-scan.sh

# using kubesec v2 api
scan_result=$(curl -sSX POST --data-binary @"k8s_deployment_service.yaml" https://v2.kubesec.io/scan)
scan_message=$(curl -sSX POST --data-binary @"k8s_deployment_service.yaml" https://v2.kubesec.io/scan | jq .[0].message -r )
scan_score=$(curl -sSX POST --data-binary @"k8s_deployment_service.yaml" https://v2.kubesec.io/scan | jq .[0].score )


# using kubesec docker image for scanning
# scan_result=$(docker run -i kubesec/kubesec:512c5e0 scan /dev/stdin < k8s_deployment_service.yaml)
# scan_message=$(docker run -i kubesec/kubesec:512c5e0 scan /dev/stdin < k8s_deployment_service.yaml | jq .[].message -r)
# scan_score=$(docker run -i kubesec/kubesec:512c5e0 scan /dev/stdin < k8s_deployment_service.yaml | jq .[].score)


    # Kubesec scan result processing
    # echo "Scan Score : $scan_score"

        if [[ "${scan_score}" -ge 5 ]]; then
            echo "Score is $scan_score"
            echo "Kubesec Scan $scan_message"
        else
            echo "Score is $scan_score, which is less than or equal to 5."
            echo "Scanning Kubernetes Resource has Failed"
            exit 1;
        fi;

################################e kubesec-scan.sh ################################


ubuntu@jenkins:~$ sh "chmod +x kube-scan.sh && ./kube-scan.sh"
sh: 0: cannot open chmod +x kube-scan.sh && ./kube-scan.sh: No such file
ubuntu@jenkins:~$ ll
total 129684
drwxr-x--- 7 ubuntu ubuntu     4096 Aug 11 08:02 ./
drwxr-xr-x 3 root   root       4096 Aug 10 13:39 ../
-rw------- 1 ubuntu ubuntu      230 Aug 11 06:52 .Xauthority
drwxrwxr-x 3 ubuntu ubuntu     4096 Aug 11 06:53 .aws/
-rw------- 1 ubuntu ubuntu      666 Aug 11 08:04 .bash_history
-rw-r--r-- 1 ubuntu ubuntu      220 Mar 31  2024 .bash_logout
-rw-r--r-- 1 ubuntu ubuntu     3771 Mar 31  2024 .bashrc
drwx------ 2 ubuntu ubuntu     4096 Aug 10 13:55 .cache/
drwxrwxr-x 3 ubuntu ubuntu     4096 Aug 11 06:55 .kube/
-rw------- 1 ubuntu ubuntu       20 Aug 11 07:08 .lesshst
-rw-r--r-- 1 ubuntu ubuntu      807 Mar 31  2024 .profile
drwx------ 2 ubuntu ubuntu     4096 Aug 10 13:40 .ssh/
-rw-r--r-- 1 ubuntu ubuntu        0 Aug 10 13:57 .sudo_as_admin_successful
-rw------- 1 ubuntu ubuntu     1675 Aug 11 08:02 .viminfo
drwxr-xr-x 3 ubuntu ubuntu     4096 Aug 10 18:16 aws/
-rw-rw-r-- 1 ubuntu ubuntu 73163750 Aug 11 06:53 awscliv2.zip
-rw-rw-r-- 1 ubuntu ubuntu     1286 Aug 11 08:02 kube-scan.sh
-rw-rw-r-- 1 ubuntu ubuntu 59556002 Aug 11 06:55 kubectl
-rw-rw-r-- 1 ubuntu ubuntu      349 Aug 11 02:43 opa-k8s-security.rego
-rw-rw-r-- 1 ubuntu ubuntu      637 Aug 11 02:21 trivy.sh
ubuntu@jenkins:~$ chmod +x kube-scan.sh
ubuntu@jenkins:~$ cat kube-scan.sh
################################e kubesec-scan.sh ################################

#!/bin/bash

#kubesec-scan.sh

# using kubesec v2 api
scan_result=$(curl -sSX POST --data-binary @"k8s_deployment_service.yaml" https://v2.kubesec.io/scan)
scan_message=$(curl -sSX POST --data-binary @"k8s_deployment_service.yaml" https://v2.kubesec.io/scan | jq .[0].message -r )
scan_score=$(curl -sSX POST --data-binary @"k8s_deployment_service.yaml" https://v2.kubesec.io/scan | jq .[0].score )


# using kubesec docker image for scanning
# scan_result=$(docker run -i kubesec/kubesec:512c5e0 scan /dev/stdin < k8s_deployment_service.yaml)
# scan_message=$(docker run -i kubesec/kubesec:512c5e0 scan /dev/stdin < k8s_deployment_service.yaml | jq .[].message -r)
# scan_score=$(docker run -i kubesec/kubesec:512c5e0 scan /dev/stdin < k8s_deployment_service.yaml | jq .[].score)


    # Kubesec scan result processing
    # echo "Scan Score : $scan_score"

        if [[ "${scan_score}" -ge 5 ]]; then
            echo "Score is $scan_score"
            echo "Kubesec Scan $scan_message"
        else
            echo "Score is $scan_score, which is less than or equal to 5."
            echo "Scanning Kubernetes Resource has Failed"
            exit 1;
        fi;

################################e kubesec-scan.sh ################################


