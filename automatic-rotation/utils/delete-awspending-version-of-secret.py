#!/usr/bin/env python3

import boto3
import os
import argparse
import traceback
from botocore.exceptions import ClientError
from botocore.config import Config


###########################
# define Class for storing infos from secret
###########################
class Secret:

    def __init__(self,id,name,description,versions):
        self.id = id
        self.name = name
        self.description = description
        self.versions = versions
        
    def findVersionPending(self):
        
        for version in self.versions.keys():
            stateList = self.versions[version]
            for sl in stateList:
                if sl == 'AWSPENDING':
                    return version
        
        return None
        
    def __str__(self):
        buffer = "\nsecretId = {}".format(self.id)
        buffer = buffer + "\nname = {}".format(self.name)
        buffer = buffer + "\ndescription = {}".format(self.description)
        buffer = buffer + "\nversions = {}".format(self.versions)
        
        return str(buffer)
    
    
###########################
# define functions for interaction with the human launcher
###########################
def ask_user(secret_id,version):
    check = str(input("Please confirm the deletion of pending version {} for secret {} ? (Y/N): ".format(version,secret_id))).lower().strip()
    try:
        if check[0] == 'y':
            return True
        elif check[0] == 'n':
            return False
        else:
            print('Invalid Input')
            return ask_user(secret_id,version)
    except Exception as error:
        print("Please enter valid inputs.")
        print(error)
        return ask_user(secret_id,version)
    


###########################
# MAIN
###########################
if __name__ == '__main__':

    AWS_REGION = "eu-west-1"
    
    try:
        
        # retrieve from command line the secret-id
        parser = argparse.ArgumentParser("delete-awspending-version-of-secret.py")
        parser.add_argument("secret_id", help="Provide the secret-id.", type=str)
        args = parser.parse_args()
        secret_id = args.secret_id
        
        # initiate boto3 client
        my_config = Config(region_name = AWS_REGION)
        client = boto3.client('secretsmanager',config=my_config)
        
        response = client.list_secrets(
            IncludePlannedDeletion=True,
            Filters=[
                {
                    'Key': 'name',
                    'Values': [
                        secret_id,
                    ]
                },
            ]
        )
        
        secretList = response['SecretList']
        if secretList is None or len(secretList) == 0:
            raise Exception("Secret not found")
        else:
            secret = secretList[0]
            arn = secret['ARN']
            description = secret['Description']
            secretVersonsToStages = secret['SecretVersionsToStages']
            
            # create our final secret                
            finalSecret = Secret(arn,secret_id,description,secretVersonsToStages)
            print(finalSecret)
            
            # find the version associated to the state 'AWSPENDING'
            version = finalSecret.findVersionPending()
            #print(version)
            
            if version is None:
                print("No Pending version was found for this secret.")
            else:
                # after confirmation of the user, we delete the 'pending' version
                if ask_user(secret_id,version):
                    print('DELETE VERSION {} for SECRET {}'.format(secret_id,version))
                    
                    response = client.update_secret_version_stage(
                        SecretId=secret_id,
                        VersionStage='AWSPENDING',
                        RemoveFromVersionId=version,
                        #MoveToVersionId='string'
                    )
                    
                    # print(response)
                    print("HTTPStatusCode : {}".format(response['ResponseMetadata']['HTTPStatusCode']))
                    
                else:
                    print('Deletion Cancelled')
            
            


    except Exception as err:
        print("Exception during processing: {0}".format(err))
        traceback.print_exc()
                
    