# Terraform automation for Azure Firewall rules example
This repo demonstrates one of manz options to abstract firewall rules to make it easier for network teams to author changes, manage work and process changes using GitHub features and safely deploy using GitHub Actions.

exit=0
for file in $(find ./rules -name *.yaml) 
do
    echo ">>> Evaluating $file <<<"
    result=$(opa eval -i $file -d ./rego -f pretty data.firewall.violation)
    echo $result | jq .[] --raw-output
    if [ "$result" == "[]" ]; then
        exit=1
    fi
    echo
done
exit $exit