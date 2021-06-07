#  Licensed to the Apache Software Foundation (ASF) under one
#  or more contributor license agreements. See the NOTICE file
#  distributed with this work for additional information
#  regarding copyright ownership. The ASF licenses this file
#  to you under the Apache License, Version 2.0 (the
#  "License"); you may not use this file except in compliance
#  with the License. You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing,
#   software distributed under the License is distributed on an
#   "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#   KIND, either express or implied. See the License for the
#   specific language governing permissions and limitations
#   under the License.

# Generated by the gRPC Python protocol compiler plugin. DO NOT EDIT!
"""Client and server classes corresponding to protobuf-defined services."""
import grpc

import custos.server.core.FederatedAuthenticationService_pb2 as FederatedAuthenticationService__pb2


class FederatedAuthenticationServiceStub(object):
    """Missing associated documentation comment in .proto file."""

    def __init__(self, channel):
        """Constructor.

        Args:
            channel: A grpc.Channel.
        """
        self.addClient = channel.unary_unary(
                '/org.apache.custos.federated.authentication.service.FederatedAuthenticationService/addClient',
                request_serializer=FederatedAuthenticationService__pb2.ClientMetadata.SerializeToString,
                response_deserializer=FederatedAuthenticationService__pb2.RegisterClientResponse.FromString,
                )
        self.updateClient = channel.unary_unary(
                '/org.apache.custos.federated.authentication.service.FederatedAuthenticationService/updateClient',
                request_serializer=FederatedAuthenticationService__pb2.ClientMetadata.SerializeToString,
                response_deserializer=FederatedAuthenticationService__pb2.Empty.FromString,
                )
        self.getClient = channel.unary_unary(
                '/org.apache.custos.federated.authentication.service.FederatedAuthenticationService/getClient',
                request_serializer=FederatedAuthenticationService__pb2.GetClientRequest.SerializeToString,
                response_deserializer=FederatedAuthenticationService__pb2.GetClientResponse.FromString,
                )
        self.deleteClient = channel.unary_unary(
                '/org.apache.custos.federated.authentication.service.FederatedAuthenticationService/deleteClient',
                request_serializer=FederatedAuthenticationService__pb2.DeleteClientRequest.SerializeToString,
                response_deserializer=FederatedAuthenticationService__pb2.Empty.FromString,
                )
        self.getOperationMetadata = channel.unary_unary(
                '/org.apache.custos.federated.authentication.service.FederatedAuthenticationService/getOperationMetadata',
                request_serializer=FederatedAuthenticationService__pb2.GetOperationsMetadataRequest.SerializeToString,
                response_deserializer=FederatedAuthenticationService__pb2.GetOperationsMetadataResponse.FromString,
                )
        self.addToCache = channel.unary_unary(
                '/org.apache.custos.federated.authentication.service.FederatedAuthenticationService/addToCache',
                request_serializer=FederatedAuthenticationService__pb2.CacheManipulationRequest.SerializeToString,
                response_deserializer=FederatedAuthenticationService__pb2.Status.FromString,
                )
        self.removeFromCache = channel.unary_unary(
                '/org.apache.custos.federated.authentication.service.FederatedAuthenticationService/removeFromCache',
                request_serializer=FederatedAuthenticationService__pb2.CacheManipulationRequest.SerializeToString,
                response_deserializer=FederatedAuthenticationService__pb2.Status.FromString,
                )
        self.getFromCache = channel.unary_unary(
                '/org.apache.custos.federated.authentication.service.FederatedAuthenticationService/getFromCache',
                request_serializer=FederatedAuthenticationService__pb2.CacheManipulationRequest.SerializeToString,
                response_deserializer=FederatedAuthenticationService__pb2.GetInstitutionsResponse.FromString,
                )
        self.getInstitutions = channel.unary_unary(
                '/org.apache.custos.federated.authentication.service.FederatedAuthenticationService/getInstitutions',
                request_serializer=FederatedAuthenticationService__pb2.CacheManipulationRequest.SerializeToString,
                response_deserializer=FederatedAuthenticationService__pb2.GetInstitutionsResponse.FromString,
                )


class FederatedAuthenticationServiceServicer(object):
    """Missing associated documentation comment in .proto file."""

    def addClient(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def updateClient(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def getClient(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def deleteClient(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def getOperationMetadata(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def addToCache(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def removeFromCache(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def getFromCache(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def getInstitutions(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')


def add_FederatedAuthenticationServiceServicer_to_server(servicer, server):
    rpc_method_handlers = {
            'addClient': grpc.unary_unary_rpc_method_handler(
                    servicer.addClient,
                    request_deserializer=FederatedAuthenticationService__pb2.ClientMetadata.FromString,
                    response_serializer=FederatedAuthenticationService__pb2.RegisterClientResponse.SerializeToString,
            ),
            'updateClient': grpc.unary_unary_rpc_method_handler(
                    servicer.updateClient,
                    request_deserializer=FederatedAuthenticationService__pb2.ClientMetadata.FromString,
                    response_serializer=FederatedAuthenticationService__pb2.Empty.SerializeToString,
            ),
            'getClient': grpc.unary_unary_rpc_method_handler(
                    servicer.getClient,
                    request_deserializer=FederatedAuthenticationService__pb2.GetClientRequest.FromString,
                    response_serializer=FederatedAuthenticationService__pb2.GetClientResponse.SerializeToString,
            ),
            'deleteClient': grpc.unary_unary_rpc_method_handler(
                    servicer.deleteClient,
                    request_deserializer=FederatedAuthenticationService__pb2.DeleteClientRequest.FromString,
                    response_serializer=FederatedAuthenticationService__pb2.Empty.SerializeToString,
            ),
            'getOperationMetadata': grpc.unary_unary_rpc_method_handler(
                    servicer.getOperationMetadata,
                    request_deserializer=FederatedAuthenticationService__pb2.GetOperationsMetadataRequest.FromString,
                    response_serializer=FederatedAuthenticationService__pb2.GetOperationsMetadataResponse.SerializeToString,
            ),
            'addToCache': grpc.unary_unary_rpc_method_handler(
                    servicer.addToCache,
                    request_deserializer=FederatedAuthenticationService__pb2.CacheManipulationRequest.FromString,
                    response_serializer=FederatedAuthenticationService__pb2.Status.SerializeToString,
            ),
            'removeFromCache': grpc.unary_unary_rpc_method_handler(
                    servicer.removeFromCache,
                    request_deserializer=FederatedAuthenticationService__pb2.CacheManipulationRequest.FromString,
                    response_serializer=FederatedAuthenticationService__pb2.Status.SerializeToString,
            ),
            'getFromCache': grpc.unary_unary_rpc_method_handler(
                    servicer.getFromCache,
                    request_deserializer=FederatedAuthenticationService__pb2.CacheManipulationRequest.FromString,
                    response_serializer=FederatedAuthenticationService__pb2.GetInstitutionsResponse.SerializeToString,
            ),
            'getInstitutions': grpc.unary_unary_rpc_method_handler(
                    servicer.getInstitutions,
                    request_deserializer=FederatedAuthenticationService__pb2.CacheManipulationRequest.FromString,
                    response_serializer=FederatedAuthenticationService__pb2.GetInstitutionsResponse.SerializeToString,
            ),
    }
    generic_handler = grpc.method_handlers_generic_handler(
            'org.apache.custos.federated.authentication.service.FederatedAuthenticationService', rpc_method_handlers)
    server.add_generic_rpc_handlers((generic_handler,))


 # This class is part of an EXPERIMENTAL API.
class FederatedAuthenticationService(object):
    """Missing associated documentation comment in .proto file."""

    @staticmethod
    def addClient(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/org.apache.custos.federated.authentication.service.FederatedAuthenticationService/addClient',
            FederatedAuthenticationService__pb2.ClientMetadata.SerializeToString,
            FederatedAuthenticationService__pb2.RegisterClientResponse.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def updateClient(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/org.apache.custos.federated.authentication.service.FederatedAuthenticationService/updateClient',
            FederatedAuthenticationService__pb2.ClientMetadata.SerializeToString,
            FederatedAuthenticationService__pb2.Empty.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def getClient(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/org.apache.custos.federated.authentication.service.FederatedAuthenticationService/getClient',
            FederatedAuthenticationService__pb2.GetClientRequest.SerializeToString,
            FederatedAuthenticationService__pb2.GetClientResponse.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def deleteClient(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/org.apache.custos.federated.authentication.service.FederatedAuthenticationService/deleteClient',
            FederatedAuthenticationService__pb2.DeleteClientRequest.SerializeToString,
            FederatedAuthenticationService__pb2.Empty.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def getOperationMetadata(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/org.apache.custos.federated.authentication.service.FederatedAuthenticationService/getOperationMetadata',
            FederatedAuthenticationService__pb2.GetOperationsMetadataRequest.SerializeToString,
            FederatedAuthenticationService__pb2.GetOperationsMetadataResponse.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def addToCache(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/org.apache.custos.federated.authentication.service.FederatedAuthenticationService/addToCache',
            FederatedAuthenticationService__pb2.CacheManipulationRequest.SerializeToString,
            FederatedAuthenticationService__pb2.Status.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def removeFromCache(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/org.apache.custos.federated.authentication.service.FederatedAuthenticationService/removeFromCache',
            FederatedAuthenticationService__pb2.CacheManipulationRequest.SerializeToString,
            FederatedAuthenticationService__pb2.Status.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def getFromCache(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/org.apache.custos.federated.authentication.service.FederatedAuthenticationService/getFromCache',
            FederatedAuthenticationService__pb2.CacheManipulationRequest.SerializeToString,
            FederatedAuthenticationService__pb2.GetInstitutionsResponse.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def getInstitutions(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/org.apache.custos.federated.authentication.service.FederatedAuthenticationService/getInstitutions',
            FederatedAuthenticationService__pb2.CacheManipulationRequest.SerializeToString,
            FederatedAuthenticationService__pb2.GetInstitutionsResponse.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)
