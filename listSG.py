import boto3

def list_security_groups_with_port_22_exposed():
    region = 'ap-south-1'  # Change this to your preferred region
    port_number = 22

    ec2_client = boto3.client('ec2', region_name=region)

    next_token = None

    while True:
        
        response = ec2_client.describe_security_groups(
            Filters=[
                {
                    'Name': 'ip-permission.from-port',
                    'Values': [str(port_number)],
                },
                {
                    'Name': 'ip-permission.to-port',
                    'Values': [str(port_number)],
                },
                {
                    'Name': 'ip-permission.cidr',
                    'Values': ['0.0.0.0/0'],
                },
            ],
            NextToken=next_token
        )

        # Process the response and print security group details
        for group in response['SecurityGroups']:
            print(f"Security Group ID: {group['GroupId']}")
            print(f"Description: {group['Description']}")
            print("Inbound Rules:")
            for permission in group['IpPermissions']:
                print(f"  From Port: {permission['FromPort']}, To Port: {permission['ToPort']}")
            print("----------------------------------------")

        # Check if there are more results to be paginated
        next_token = response.get('NextToken')
        if not next_token:
            break

if __name__ == "__main__":
    list_security_groups_with_port_22_exposed()
