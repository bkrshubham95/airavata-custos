
�x
google/api/http.proto
google.api"y
Http*
rules (2.google.api.HttpRuleRrulesE
fully_decode_reserved_expansion (RfullyDecodeReservedExpansion"�
HttpRule
selector (	Rselector
get (	H Rget
put (	H Rput
post (	H Rpost
delete (	H Rdelete
patch (	H Rpatch7
custom (2.google.api.CustomHttpPatternH Rcustom
body (	Rbody#
response_body (	RresponseBodyE
additional_bindings (2.google.api.HttpRuleRadditionalBindingsB	
pattern";
CustomHttpPattern
kind (	Rkind
path (	RpathBj
com.google.apiB	HttpProtoPZAgoogle.golang.org/genproto/googleapis/api/annotations;annotations��GAPIJ�s
 �
�
 2� Copyright 2019 Google LLC.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.



 

 
	
 

 X
	
 X

 "
	

 "

 *
	
 *

 '
	
 '

 "
	
$ "
�
  *� Defines the HTTP configuration for an API service. It contains a list of
 [HttpRule][google.api.HttpRule], each specifying the mapping of an RPC method
 to one or more HTTP REST API methods.



 
�
  !� A list of HTTP configuration rules that apply to individual API methods.

 **NOTE:** All service configuration rules follow "last one wins" order.


  !


  !

  !

  !
�
 )+� When set to true, URL path parameters will be fully URI-decoded except in
 cases of single segment matches in reserved expansion, where "%2F" will be
 left encoded.

 The default behavior is to not decode RFC 6570 reserved characters in multi
 segment matches.


 )

 )&

 ))*
�S
� ��S # gRPC Transcoding

 gRPC Transcoding is a feature for mapping between a gRPC method and one or
 more HTTP REST endpoints. It allows developers to build a single API service
 that supports both gRPC APIs and REST APIs. Many systems, including [Google
 APIs](https://github.com/googleapis/googleapis),
 [Cloud Endpoints](https://cloud.google.com/endpoints), [gRPC
 Gateway](https://github.com/grpc-ecosystem/grpc-gateway),
 and [Envoy](https://github.com/envoyproxy/envoy) proxy support this feature
 and use it for large scale production services.

 `HttpRule` defines the schema of the gRPC/REST mapping. The mapping specifies
 how different portions of the gRPC request message are mapped to the URL
 path, URL query parameters, and HTTP request body. It also controls how the
 gRPC response message is mapped to the HTTP response body. `HttpRule` is
 typically specified as an `google.api.http` annotation on the gRPC method.

 Each mapping specifies a URL path template and an HTTP method. The path
 template may refer to one or more fields in the gRPC request message, as long
 as each field is a non-repeated field with a primitive (non-message) type.
 The path template controls how fields of the request message are mapped to
 the URL path.

 Example:

     service Messaging {
       rpc GetMessage(GetMessageRequest) returns (Message) {
         option (google.api.http) = {
             get: "/v1/{name=messages/*}"
         };
       }
     }
     message GetMessageRequest {
       string name = 1; // Mapped to URL path.
     }
     message Message {
       string text = 1; // The resource content.
     }

 This enables an HTTP REST to gRPC mapping as below:

 HTTP | gRPC
 -----|-----
 `GET /v1/messages/123456`  | `GetMessage(name: "messages/123456")`

 Any fields in the request message which are not bound by the path template
 automatically become HTTP query parameters if there is no HTTP request body.
 For example:

     service Messaging {
       rpc GetMessage(GetMessageRequest) returns (Message) {
         option (google.api.http) = {
             get:"/v1/messages/{message_id}"
         };
       }
     }
     message GetMessageRequest {
       message SubMessage {
         string subfield = 1;
       }
       string message_id = 1; // Mapped to URL path.
       int64 revision = 2;    // Mapped to URL query parameter `revision`.
       SubMessage sub = 3;    // Mapped to URL query parameter `sub.subfield`.
     }

 This enables a HTTP JSON to RPC mapping as below:

 HTTP | gRPC
 -----|-----
 `GET /v1/messages/123456?revision=2&sub.subfield=foo` |
 `GetMessage(message_id: "123456" revision: 2 sub: SubMessage(subfield:
 "foo"))`

 Note that fields which are mapped to URL query parameters must have a
 primitive type or a repeated primitive type or a non-repeated message type.
 In the case of a repeated type, the parameter can be repeated in the URL
 as `...?param=A&param=B`. In the case of a message type, each field of the
 message is mapped to a separate parameter, such as
 `...?foo.a=A&foo.b=B&foo.c=C`.

 For HTTP methods that allow a request body, the `body` field
 specifies the mapping. Consider a REST update method on the
 message resource collection:

     service Messaging {
       rpc UpdateMessage(UpdateMessageRequest) returns (Message) {
         option (google.api.http) = {
           patch: "/v1/messages/{message_id}"
           body: "message"
         };
       }
     }
     message UpdateMessageRequest {
       string message_id = 1; // mapped to the URL
       Message message = 2;   // mapped to the body
     }

 The following HTTP JSON to RPC mapping is enabled, where the
 representation of the JSON in the request body is determined by
 protos JSON encoding:

 HTTP | gRPC
 -----|-----
 `PATCH /v1/messages/123456 { "text": "Hi!" }` | `UpdateMessage(message_id:
 "123456" message { text: "Hi!" })`

 The special name `*` can be used in the body mapping to define that
 every field not bound by the path template should be mapped to the
 request body.  This enables the following alternative definition of
 the update method:

     service Messaging {
       rpc UpdateMessage(Message) returns (Message) {
         option (google.api.http) = {
           patch: "/v1/messages/{message_id}"
           body: "*"
         };
       }
     }
     message Message {
       string message_id = 1;
       string text = 2;
     }


 The following HTTP JSON to RPC mapping is enabled:

 HTTP | gRPC
 -----|-----
 `PATCH /v1/messages/123456 { "text": "Hi!" }` | `UpdateMessage(message_id:
 "123456" text: "Hi!")`

 Note that when using `*` in the body mapping, it is not possible to
 have HTTP parameters, as all fields not bound by the path end in
 the body. This makes this option more rarely used in practice when
 defining REST APIs. The common usage of `*` is in custom methods
 which don't use the URL at all for transferring data.

 It is possible to define multiple HTTP methods for one RPC by using
 the `additional_bindings` option. Example:

     service Messaging {
       rpc GetMessage(GetMessageRequest) returns (Message) {
         option (google.api.http) = {
           get: "/v1/messages/{message_id}"
           additional_bindings {
             get: "/v1/users/{user_id}/messages/{message_id}"
           }
         };
       }
     }
     message GetMessageRequest {
       string message_id = 1;
       string user_id = 2;
     }

 This enables the following two alternative HTTP JSON to RPC mappings:

 HTTP | gRPC
 -----|-----
 `GET /v1/messages/123456` | `GetMessage(message_id: "123456")`
 `GET /v1/users/me/messages/123456` | `GetMessage(user_id: "me" message_id:
 "123456")`

 ## Rules for HTTP mapping

 1. Leaf request fields (recursive expansion nested messages in the request
    message) are classified into three categories:
    - Fields referred by the path template. They are passed via the URL path.
    - Fields referred by the [HttpRule.body][google.api.HttpRule.body]. They are passed via the HTTP
      request body.
    - All other fields are passed via the URL query parameters, and the
      parameter name is the field path in the request message. A repeated
      field can be represented as multiple query parameters under the same
      name.
  2. If [HttpRule.body][google.api.HttpRule.body] is "*", there is no URL query parameter, all fields
     are passed via URL path and HTTP request body.
  3. If [HttpRule.body][google.api.HttpRule.body] is omitted, there is no HTTP request body, all
     fields are passed via URL path and URL query parameters.

 ### Path template syntax

     Template = "/" Segments [ Verb ] ;
     Segments = Segment { "/" Segment } ;
     Segment  = "*" | "**" | LITERAL | Variable ;
     Variable = "{" FieldPath [ "=" Segments ] "}" ;
     FieldPath = IDENT { "." IDENT } ;
     Verb     = ":" LITERAL ;

 The syntax `*` matches a single URL path segment. The syntax `**` matches
 zero or more URL path segments, which must be the last part of the URL path
 except the `Verb`.

 The syntax `Variable` matches part of the URL path as specified by its
 template. A variable template must not contain other variables. If a variable
 matches a single path segment, its template may be omitted, e.g. `{var}`
 is equivalent to `{var=*}`.

 The syntax `LITERAL` matches literal text in the URL path. If the `LITERAL`
 contains any reserved character, such characters should be percent-encoded
 before the matching.

 If a variable contains exactly one path segment, such as `"{var}"` or
 `"{var=*}"`, when such a variable is expanded into a URL path on the client
 side, all characters except `[-_.~0-9a-zA-Z]` are percent-encoded. The
 server side does the reverse decoding. Such variables show up in the
 [Discovery
 Document](https://developers.google.com/discovery/v1/reference/apis) as
 `{var}`.

 If a variable contains multiple path segments, such as `"{var=foo/*}"`
 or `"{var=**}"`, when such a variable is expanded into a URL path on the
 client side, all characters except `[-_.~/0-9a-zA-Z]` are percent-encoded.
 The server side does the reverse decoding, except "%2F" and "%2f" are left
 unchanged. Such variables show up in the
 [Discovery
 Document](https://developers.google.com/discovery/v1/reference/apis) as
 `{+var}`.

 ## Using gRPC API Service Configuration

 gRPC API Service Configuration (service config) is a configuration language
 for configuring a gRPC service to become a user-facing product. The
 service config is simply the YAML representation of the `google.api.Service`
 proto message.

 As an alternative to annotating your proto file, you can configure gRPC
 transcoding in your service config YAML files. You do this by specifying a
 `HttpRule` that maps the gRPC method to a REST endpoint, achieving the same
 effect as the proto annotation. This can be particularly useful if you
 have a proto that is reused in multiple services. Note that any transcoding
 specified in the service config will override any matching transcoding
 configuration in the proto.

 Example:

     http:
       rules:
         # Selects a gRPC method and applies HttpRule to it.
         - selector: example.v1.Messaging.GetMessage
           get: /v1/messages/{message_id}/{sub.subfield}

 ## Special notes

 When gRPC Transcoding is used to map a gRPC to JSON REST endpoints, the
 proto to JSON conversion must follow the [proto3
 specification](https://developers.google.com/protocol-buffers/docs/proto3#json).

 While the single segment variable follows the semantics of
 [RFC 6570](https://tools.ietf.org/html/rfc6570) Section 3.2.2 Simple String
 Expansion, the multi segment variable **does not** follow RFC 6570 Section
 3.2.3 Reserved Expansion. The reason is that the Reserved Expansion
 does not expand special characters like `?` and `#`, which would lead
 to invalid URLs. As the result, gRPC Transcoding uses a custom encoding
 for multi segment variables.

 The path variables **must not** refer to any repeated or mapped field,
 because client libraries are not capable of handling such variable expansion.

 The path variables **must not** capture the leading "/" character. The reason
 is that the most common use case "{var}" does not capture the leading "/"
 character. For consistency, all path variables must share the same behavior.

 Repeated message fields must not be mapped to URL query parameters, because
 no client library can support such complicated mapping.

 If an API needs to use a JSON array for request or response body, it can map
 the request or response body to a repeated field. However, some gRPC
 Transcoding implementations may not support this feature.


�
�
 � Selects a method to which this rule applies.

 Refer to [selector][google.api.DocumentationRule.selector] for syntax details.


 �

 �	

 �
�
 ��� Determines the URL pattern is matched by this rules. This pattern can be
 used with any of the {get|put|post|delete|patch} methods. A custom method
 can be defined using the 'custom' field.


 �
\
�N Maps to HTTP GET. Used for listing and getting information about
 resources.


�


�

�
@
�2 Maps to HTTP PUT. Used for replacing a resource.


�


�

�
X
�J Maps to HTTP POST. Used for creating a resource or performing an action.


�


�

�
B
�4 Maps to HTTP DELETE. Used for deleting a resource.


�


�

�
A
�3 Maps to HTTP PATCH. Used for updating a resource.


�


�

�
�
�!� The custom pattern is used for specifying an HTTP method that is not
 included in the `pattern` field, such as HEAD, or "*" to leave the
 HTTP method unspecified for this rule. The wild-card rule is useful
 for services that provide content to Web (HTML) clients.


�

�

� 
�
�� The name of the request field whose value is mapped to the HTTP request
 body, or `*` for mapping all request fields not captured by the path
 pattern to the HTTP body, or omitted for not having any HTTP request body.

 NOTE: the referred field must be present at the top-level of the request
 message type.


�

�	

�
�
�� Optional. The name of the response field whose value is mapped to the HTTP
 response body. When omitted, the entire response message will be used
 as the HTTP response body.

 NOTE: The referred field must be present at the top-level of the response
 message type.


�

�	

�
�
	�-� Additional HTTP bindings for the selector. Nested bindings must
 not contain an `additional_bindings` field themselves (that is,
 the nesting may only be one level deep).


	�


	�

	�'

	�*,
G
� �9 A custom pattern is used for defining custom HTTP verb.


�
2
 �$ The name of this custom HTTP verb.


 �

 �	

 �
5
�' The path matched by this custom verb.


�

�	

�bproto3
��
 google/protobuf/descriptor.protogoogle.protobuf"M
FileDescriptorSet8
file (2$.google.protobuf.FileDescriptorProtoRfile"�
FileDescriptorProto
name (	Rname
package (	Rpackage

dependency (	R
dependency+
public_dependency
 (RpublicDependency'
weak_dependency (RweakDependencyC
message_type (2 .google.protobuf.DescriptorProtoRmessageTypeA
	enum_type (2$.google.protobuf.EnumDescriptorProtoRenumTypeA
service (2'.google.protobuf.ServiceDescriptorProtoRserviceC
	extension (2%.google.protobuf.FieldDescriptorProtoR	extension6
options (2.google.protobuf.FileOptionsRoptionsI
source_code_info	 (2.google.protobuf.SourceCodeInfoRsourceCodeInfo
syntax (	Rsyntax"�
DescriptorProto
name (	Rname;
field (2%.google.protobuf.FieldDescriptorProtoRfieldC
	extension (2%.google.protobuf.FieldDescriptorProtoR	extensionA
nested_type (2 .google.protobuf.DescriptorProtoR
nestedTypeA
	enum_type (2$.google.protobuf.EnumDescriptorProtoRenumTypeX
extension_range (2/.google.protobuf.DescriptorProto.ExtensionRangeRextensionRangeD

oneof_decl (2%.google.protobuf.OneofDescriptorProtoR	oneofDecl9
options (2.google.protobuf.MessageOptionsRoptionsU
reserved_range	 (2..google.protobuf.DescriptorProto.ReservedRangeRreservedRange#
reserved_name
 (	RreservedNamez
ExtensionRange
start (Rstart
end (Rend@
options (2&.google.protobuf.ExtensionRangeOptionsRoptions7
ReservedRange
start (Rstart
end (Rend"|
ExtensionRangeOptionsX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����"�
FieldDescriptorProto
name (	Rname
number (RnumberA
label (2+.google.protobuf.FieldDescriptorProto.LabelRlabel>
type (2*.google.protobuf.FieldDescriptorProto.TypeRtype
	type_name (	RtypeName
extendee (	Rextendee#
default_value (	RdefaultValue
oneof_index	 (R
oneofIndex
	json_name
 (	RjsonName7
options (2.google.protobuf.FieldOptionsRoptions"�
Type
TYPE_DOUBLE

TYPE_FLOAT

TYPE_INT64
TYPE_UINT64

TYPE_INT32
TYPE_FIXED64
TYPE_FIXED32
	TYPE_BOOL
TYPE_STRING	

TYPE_GROUP

TYPE_MESSAGE

TYPE_BYTES
TYPE_UINT32
	TYPE_ENUM
TYPE_SFIXED32
TYPE_SFIXED64
TYPE_SINT32
TYPE_SINT64"C
Label
LABEL_OPTIONAL
LABEL_REQUIRED
LABEL_REPEATED"c
OneofDescriptorProto
name (	Rname7
options (2.google.protobuf.OneofOptionsRoptions"�
EnumDescriptorProto
name (	Rname?
value (2).google.protobuf.EnumValueDescriptorProtoRvalue6
options (2.google.protobuf.EnumOptionsRoptions]
reserved_range (26.google.protobuf.EnumDescriptorProto.EnumReservedRangeRreservedRange#
reserved_name (	RreservedName;
EnumReservedRange
start (Rstart
end (Rend"�
EnumValueDescriptorProto
name (	Rname
number (Rnumber;
options (2!.google.protobuf.EnumValueOptionsRoptions"�
ServiceDescriptorProto
name (	Rname>
method (2&.google.protobuf.MethodDescriptorProtoRmethod9
options (2.google.protobuf.ServiceOptionsRoptions"�
MethodDescriptorProto
name (	Rname

input_type (	R	inputType
output_type (	R
outputType8
options (2.google.protobuf.MethodOptionsRoptions0
client_streaming (:falseRclientStreaming0
server_streaming (:falseRserverStreaming"�	
FileOptions!
java_package (	RjavaPackage0
java_outer_classname (	RjavaOuterClassname5
java_multiple_files
 (:falseRjavaMultipleFilesD
java_generate_equals_and_hash (BRjavaGenerateEqualsAndHash:
java_string_check_utf8 (:falseRjavaStringCheckUtf8S
optimize_for	 (2).google.protobuf.FileOptions.OptimizeMode:SPEEDRoptimizeFor

go_package (	R	goPackage5
cc_generic_services (:falseRccGenericServices9
java_generic_services (:falseRjavaGenericServices5
py_generic_services (:falseRpyGenericServices7
php_generic_services* (:falseRphpGenericServices%

deprecated (:falseR
deprecated/
cc_enable_arenas (:falseRccEnableArenas*
objc_class_prefix$ (	RobjcClassPrefix)
csharp_namespace% (	RcsharpNamespace!
swift_prefix' (	RswiftPrefix(
php_class_prefix( (	RphpClassPrefix#
php_namespace) (	RphpNamespace4
php_metadata_namespace, (	RphpMetadataNamespace!
ruby_package- (	RrubyPackageX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption":
OptimizeMode	
SPEED
	CODE_SIZE
LITE_RUNTIME*	�����J&'"�
MessageOptions<
message_set_wire_format (:falseRmessageSetWireFormatL
no_standard_descriptor_accessor (:falseRnoStandardDescriptorAccessor%

deprecated (:falseR
deprecated
	map_entry (RmapEntryX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����J	J	
"�
FieldOptionsA
ctype (2#.google.protobuf.FieldOptions.CType:STRINGRctype
packed (RpackedG
jstype (2$.google.protobuf.FieldOptions.JSType:	JS_NORMALRjstype
lazy (:falseRlazy%

deprecated (:falseR
deprecated
weak
 (:falseRweakX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption"/
CType

STRING 
CORD
STRING_PIECE"5
JSType
	JS_NORMAL 
	JS_STRING
	JS_NUMBER*	�����J"s
OneofOptionsX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����"�
EnumOptions
allow_alias (R
allowAlias%

deprecated (:falseR
deprecatedX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����J"�
EnumValueOptions%

deprecated (:falseR
deprecatedX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����"�
ServiceOptions%

deprecated! (:falseR
deprecatedX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����"�
MethodOptions%

deprecated! (:falseR
deprecatedq
idempotency_level" (2/.google.protobuf.MethodOptions.IdempotencyLevel:IDEMPOTENCY_UNKNOWNRidempotencyLevelX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption"P
IdempotencyLevel
IDEMPOTENCY_UNKNOWN 
NO_SIDE_EFFECTS

IDEMPOTENT*	�����"�
UninterpretedOptionA
name (2-.google.protobuf.UninterpretedOption.NamePartRname)
identifier_value (	RidentifierValue,
positive_int_value (RpositiveIntValue,
negative_int_value (RnegativeIntValue!
double_value (RdoubleValue!
string_value (RstringValue'
aggregate_value (	RaggregateValueJ
NamePart
	name_part (	RnamePart!
is_extension (RisExtension"�
SourceCodeInfoD
location (2(.google.protobuf.SourceCodeInfo.LocationRlocation�
Location
path (BRpath
span (BRspan)
leading_comments (	RleadingComments+
trailing_comments (	RtrailingComments:
leading_detached_comments (	RleadingDetachedComments"�
GeneratedCodeInfoM

annotation (2-.google.protobuf.GeneratedCodeInfo.AnnotationR
annotationm

Annotation
path (BRpath
source_file (	R
sourceFile
begin (Rbegin
end (RendB�
com.google.protobufBDescriptorProtosHZ>github.com/golang/protobuf/protoc-gen-go/descriptor;descriptor��GPB�Google.Protobuf.ReflectionJʾ
' �
�
' 2� Protocol Buffers - Google's data interchange format
 Copyright 2008 Google Inc.  All rights reserved.
 https://developers.google.com/protocol-buffers/

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

     * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following disclaimer
 in the documentation and/or other materials provided with the
 distribution.
     * Neither the name of Google Inc. nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
2� Author: kenton@google.com (Kenton Varda)
  Based on original Protocol Buffers design by
  Sanjay Ghemawat, Jeff Dean, and others.

 The messages in this file describe the definitions found in .proto files.
 A valid .proto file can be translated directly to a FileDescriptorProto
 without any other information (e.g. without reading its imports).


) 

+ U
	
+ U

, ,
	
, ,

- 1
	
- 1

. 7
	
%. 7

/ !
	
$/ !

0 
	
0 

4 

	4 t descriptor.proto must be optimized for speed because reflection-based
 algorithms don't work during bootstrapping.

j
 8 :^ The protocol compiler can output a FileDescriptorSet containing the .proto
 files it parses.



 8

  9(

  9


  9

  9#

  9&'
/
= Z# Describes a complete .proto file.



=
9
 >", file name, relative to root of source tree


 >


 >

 >

 >
*
?" e.g. "foo", "foo.bar", etc.


?


?

?

?
4
B!' Names of files imported by this file.


B


B

B

B 
Q
D(D Indexes of the public imported files in the dependency list above.


D


D

D"

D%'
z
G&m Indexes of the weak imported files in the dependency list.
 For Google-internal migration only. Do not use.


G


G

G 

G#%
6
J,) All top-level definitions in this file.


J


J

J'

J*+

K-

K


K

K(

K+,

L.

L


L!

L")

L,-

M.

M


M

M )

M,-

	O#

	O


	O

	O

	O!"
�

U/� This field contains optional information about the original source code.
 You may safely remove this entire field without harming runtime
 functionality of the descriptors -- the information is needed only by
 development tools.



U



U


U*


U-.
]
YP The syntax of the proto file.
 The supported values are "proto2" and "proto3".


Y


Y

Y

Y
'
] } Describes a message type.



]

 ^

 ^


 ^

 ^

 ^

`*

`


`

` %

`()

a.

a


a

a )

a,-

c+

c


c

c&

c)*

d-

d


d

d(

d+,

 fk

 f


  g" Inclusive.


  g

  g

  g

  g

 h" Exclusive.


 h

 h

 h

 h

 j/

 j

 j"

 j#*

 j-.

l.

l


l

l)

l,-

n/

n


n

n *

n-.

p&

p


p

p!

p$%
�
ux� Range of reserved tag numbers. Reserved tag numbers may not be used by
 fields or extension ranges in the same message. Reserved ranges may
 not overlap.


u


 v" Inclusive.


 v

 v

 v

 v

w" Exclusive.


w

w

w

w

y,

y


y

y'

y*+
�
	|%u Reserved field names, which may not be used by fields in the same message.
 A given name may only be reserved once.


	|


	|

	|

	|"$

 �



O
 �:A The parser stores options it doesn't recognize here. See above.


 �


 �

 �3

 �69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �
3
� �% Describes a field within a message.


�

 ��

 �
S
  �C 0 is reserved for errors.
 Order is weird for historical reasons.


  �

  �

 �

 �

 �
w
 �g Not ZigZag encoded.  Negative numbers take 10 bytes.  Use TYPE_SINT64 if
 negative values are likely.


 �

 �

 �

 �

 �
w
 �g Not ZigZag encoded.  Negative numbers take 10 bytes.  Use TYPE_SINT32 if
 negative values are likely.


 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �
�
 	�� Tag-delimited aggregate.
 Group type is deprecated and not supported in proto3. However, Proto3
 implementations should still be able to parse the group wire format and
 treat group fields as unknown fields.


 	�

 	�
-
 
�" Length-delimited aggregate.


 
�

 
�
#
 � New in version 2.


 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �
'
 �" Uses ZigZag encoding.


 �

 �
'
 �" Uses ZigZag encoding.


 �

 �

��

�
*
 � 0 is reserved for errors


 �

 �

�

�

�

�

�

�

 �

 �


 �

 �

 �

�

�


�

�

�

�

�


�

�

�
�
�� If type_name is set, this need not be set.  If both this and type_name
 are set, this must be one of TYPE_ENUM, TYPE_MESSAGE or TYPE_GROUP.


�


�

�

�
�
� � For message and enum types, this is the name of the type.  If the name
 starts with a '.', it is fully-qualified.  Otherwise, C++-like scoping
 rules are used to find the type (i.e. first the nested types within this
 message are searched, then within the parent, on up to the root
 namespace).


�


�

�

�
~
�p For extensions, this is the name of the type being extended.  It is
 resolved in the same manner as type_name.


�


�

�

�
�
�$� For numeric types, contains the original text representation of the value.
 For booleans, "true" or "false".
 For strings, contains the default text contents (not escaped in any way).
 For bytes, contains the C escaped value.  All bytes >= 128 are escaped.
 TODO(kenton):  Base-64 encode?


�


�

�

�"#
�
�!v If set, gives the index of a oneof in the containing type's oneof_decl
 list.  This field is a member of that oneof.


�


�

�

� 
�
�!� JSON name of this field. The value is set by protocol compiler. If the
 user has set a "json_name" option on this field, that option's value
 will be used. Otherwise, it's deduced from the field's name by converting
 it to camelCase.


�


�

�

� 

	�$

	�


	�

	�

	�"#
"
� � Describes a oneof.


�

 �

 �


 �

 �

 �

�$

�


�

�

�"#
'
� � Describes an enum type.


�

 �

 �


 �

 �

 �

�.

�


�#

�$)

�,-

�#

�


�

�

�!"
�
 ��� Range of reserved numeric values. Reserved values may not be used by
 entries in the same enum. Reserved ranges may not overlap.

 Note that this is distinct from DescriptorProto.ReservedRange in that it
 is inclusive such that it can appropriately represent the entire int32
 domain.


 �


  �" Inclusive.


  �

  �

  �

  �

 �" Inclusive.


 �

 �

 �

 �
�
�0� Range of reserved numeric values. Reserved numeric values may not be used
 by enum values in the same enum declaration. Reserved ranges may not
 overlap.


�


�

�+

�./
l
�$^ Reserved enum value names, which may not be reused. A given name may only
 be reserved once.


�


�

�

�"#
1
� �# Describes a value within an enum.


� 

 �

 �


 �

 �

 �

�

�


�

�

�

�(

�


�

�#

�&'
$
� � Describes a service.


�

 �

 �


 �

 �

 �

�,

�


� 

�!'

�*+

�&

�


�

�!

�$%
0
	� �" Describes a method of a service.


	�

	 �

	 �


	 �

	 �

	 �
�
	�!� Input and output type names.  These are resolved in the same way as
 FieldDescriptorProto.type_name, but must refer to a message type.


	�


	�

	�

	� 

	�"

	�


	�

	�

	� !

	�%

	�


	�

	� 

	�#$
E
	�77 Identifies if client streams multiple client messages


	�


	�

	� 

	�#$

	�%6

	�05
E
	�77 Identifies if server streams multiple server messages


	�


	�

	� 

	�#$

	�%6

	�05
�

� �2N ===================================================================
 Options
2� Each of the definitions above may have "options" attached.  These are
 just annotations which may cause code to be generated slightly differently
 or may contain hints for code that manipulates protocol messages.

 Clients may define custom options as extensions of the *Options messages.
 These extensions may not yet be known at parsing time, so the parser cannot
 store the values in them.  Instead it stores them in a field in the *Options
 message called uninterpreted_option. This field must have the same name
 across all *Options messages. We then use this field to populate the
 extensions when we build a descriptor, at which point all protos have been
 parsed and so all extensions are known.

 Extension numbers for custom options may be chosen as follows:
 * For options which will only be used within a single application or
   organization, or for experimental options, use field numbers 50000
   through 99999.  It is up to you to ensure that you do not use the
   same number for multiple options.
 * For options which will be published and used publicly by multiple
   independent entities, e-mail protobuf-global-extension-registry@google.com
   to reserve extension numbers. Simply provide your project name (e.g.
   Objective-C plugin) and your project website (if available) -- there's no
   need to explain how you intend to use them. Usually you only need one
   extension number. You can declare multiple options with only one extension
   number by putting them in a sub-message. See the Custom Options section of
   the docs for examples:
   https://developers.google.com/protocol-buffers/docs/proto#options
   If this turns out to be popular, a web service will be set up
   to automatically assign option numbers.



�
�

 �#� Sets the Java package where classes generated from this .proto will be
 placed.  By default, the proto package is used, but this is often
 inappropriate because proto packages do not normally start with backwards
 domain names.



 �



 �


 �


 �!"
�

�+� If set, all the classes from the .proto file are wrapped in a single
 outer class with the given name.  This applies to both Proto1
 (equivalent to the old "--one_java_file" option) and Proto2 (where
 a .proto always translates to a single class, but you may want to
 explicitly choose the class name).



�



�


�&


�)*
�

�;� If set true, then the Java code generator will generate a separate .java
 file for each top-level message, enum, and service defined in the .proto
 file.  Thus, these types will *not* be nested inside the outer class
 named by java_outer_classname.  However, the outer class will still be
 generated to contain the file's getDescriptor() method as well as any
 top-level extensions defined in the file.



�



�


�#


�&(


�):


�49
)

�E This option does nothing.



�



�


�-


�02


�3D


�4C
�

�>� If set true, then the Java2 code generator will generate code that
 throws an exception whenever an attempt is made to assign a non-UTF-8
 byte sequence to a string field.
 Message reflection will do the same.
 However, an extension field still accepts non-UTF-8 byte sequences.
 This option has no effect on when used with the lite runtime.



�



�


�&


�)+


�,=


�7<
L

 ��< Generated classes can be optimized for speed or code size.



 �
D

  �"4 Generate complete code for parsing, serialization,



  �	


  �
G

 � etc.
"/ Use ReflectionOps to implement these methods.



 �


 �
G

 �"7 Generate code using MessageLite and the lite runtime.



 �


 �


�;


�



�


�$


�'(


�):


�49
�

�"� Sets the Go package where structs generated from this .proto will be
 placed. If omitted, the Go package will be derived from the following:
   - The basename of the package import path, if provided.
   - Otherwise, the package statement in the .proto file, if present.
   - Otherwise, the basename of the .proto file, without extension.



�



�


�


�!
�

�;� Should generic services be generated in each language?  "Generic" services
 are not specific to any particular RPC system.  They are generated by the
 main code generators in each language (without additional plugins).
 Generic services were the only kind of service generation supported by
 early versions of google.protobuf.

 Generic services are now considered deprecated in favor of using plugins
 that generate code specific to your particular RPC system.  Therefore,
 these default to false.  Old code which depends on generic services should
 explicitly set them to true.



�



�


�#


�&(


�):


�49


�=


�



�


�%


�(*


�+<


�6;


	�;


	�



	�


	�#


	�&(


	�):


	�49



�<



�




�



�$



�')



�*;



�5:
�

�2� Is this file deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for everything in the file, or it will be completely ignored; in the very
 least, this is a formalization for deprecating files.



�



�


�


�


� 1


�+0


�8q Enables the use of arenas for the proto messages in this file. This applies
 only to generated classes for C++.



�



�


� 


�#%


�&7


�16
�

�)� Sets the objective c class prefix which is prepended to all objective c
 generated classes from this .proto. There is no default.



�



�


�#


�&(
I

�(; Namespace for generated classes; defaults to the package.



�



�


�"


�%'
�

�$� By default Swift generators will take the proto package and CamelCase it
 replacing '.' with underscore and use that to prefix the types/symbols
 defined. When this options is provided, they will use this value instead
 to prefix the types/symbols defined.



�



�


�


�!#
~

�(p Sets the php class prefix which is prepended to all php generated classes
 from this .proto. Default is empty.



�



�


�"


�%'
�

�%� Use this option to change the namespace of php generated classes. Default
 is empty. When this option is empty, the package name will be used for
 determining the namespace.



�



�


�


�"$
�

�.� Use this option to change the namespace of php generated metadata classes.
 Default is empty. When this option is empty, the proto file name will be
 used for determining the namespace.



�



�


�(


�+-
�

�$� Use this option to change the package of ruby generated classes. Default
 is empty. When this option is not set, the package name will be used for
 determining the ruby package.



�



�


�


�!#
|

�:n The parser stores options it doesn't recognize here.
 See the documentation for the "Options" section above.



�



�


�3


�69
�

�z Clients can define custom options in extensions of this message.
 See the documentation for the "Options" section above.



 �


 �


 �


	�


	 �


	 �


	 �

� �

�
�
 �>� Set true to use the old proto1 MessageSet wire format for extensions.
 This is provided for backwards-compatibility with the MessageSet wire
 format.  You should not use this for any other reason:  It's less
 efficient, has fewer features, and is more complicated.

 The message must be defined exactly as follows:
   message Foo {
     option message_set_wire_format = true;
     extensions 4 to max;
   }
 Note that the message cannot have any defined fields; MessageSets only
 have extensions.

 All extensions of your type must be singular messages; e.g. they cannot
 be int32s, enums, or repeated messages.

 Because this is an option, the above two restrictions are not enforced by
 the protocol compiler.


 �


 �

 �'

 �*+

 �,=

 �7<
�
�F� Disables the generation of the standard "descriptor()" accessor, which can
 conflict with a field of the same name.  This is meant to make migration
 from proto1 easier; new code should avoid fields named "descriptor".


�


�

�/

�23

�4E

�?D
�
�1� Is this message deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for the message, or it will be completely ignored; in the very least,
 this is a formalization for deprecating messages.


�


�

�

�

�0

�*/
�
�� Whether the message is an automatically generated map entry type for the
 maps field.

 For maps fields:
     map<KeyType, ValueType> map_field = 1;
 The parsed descriptor looks like:
     message MapFieldEntry {
         option map_entry = true;
         optional KeyType key = 1;
         optional ValueType value = 2;
     }
     repeated MapFieldEntry map_field = 1;

 Implementations may choose not to generate the map_entry=true message, but
 use a native map in the target language to hold the keys and values.
 The reflection APIs in such implementations still need to work as
 if the field is a repeated message field.

 NOTE: Do not set the option in .proto files. Always use the maps syntax
 instead. The option should only be implicitly set by the proto compiler
 parser.


�


�

�

�
$
	�" javalite_serializable


	 �

	 �

	 �

	�" javanano_as_lite


	�

	�

	�
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

� �

�
�
 �.� The ctype option instructs the C++ code generator to use a different
 representation of the field than it normally would.  See the specific
 options below.  This option is not yet implemented in the open source
 release -- sorry, we'll try to include it in a future version!


 �


 �

 �

 �

 �-

 �&,

 ��

 �

  � Default mode.


  �


  �

 �

 �

 �

 �

 �

 �
�
�� The packed option can be enabled for repeated primitive fields to enable
 a more efficient representation on the wire. Rather than repeatedly
 writing the tag and type for each element, the entire array is encoded as
 a single length-delimited blob. In proto3, only explicit setting it to
 false will avoid using packed encoding.


�


�

�

�
�
�3� The jstype option determines the JavaScript type used for values of the
 field.  The option is permitted only for 64 bit integral and fixed types
 (int64, uint64, sint64, fixed64, sfixed64).  A field with jstype JS_STRING
 is represented as JavaScript string, which avoids loss of precision that
 can happen when a large value is converted to a floating point JavaScript.
 Specifying JS_NUMBER for the jstype causes the generated JavaScript code to
 use the JavaScript "number" type.  The behavior of the default option
 JS_NORMAL is implementation dependent.

 This option is an enum to permit additional types to be added, e.g.
 goog.math.Integer.


�


�

�

�

�2

�(1

��

�
'
 � Use the default type.


 �

 �
)
� Use JavaScript strings.


�

�
)
� Use JavaScript numbers.


�

�
�
�+� Should this field be parsed lazily?  Lazy applies only to message-type
 fields.  It means that when the outer message is initially parsed, the
 inner message's contents will not be parsed but instead stored in encoded
 form.  The inner message will actually be parsed when it is first accessed.

 This is only a hint.  Implementations are free to choose whether to use
 eager or lazy parsing regardless of the value of this option.  However,
 setting this option true suggests that the protocol author believes that
 using lazy parsing on this field is worth the additional bookkeeping
 overhead typically needed to implement it.

 This option does not affect the public interface of any generated code;
 all method signatures remain the same.  Furthermore, thread-safety of the
 interface is not affected by this option; const methods remain safe to
 call from multiple threads concurrently, while non-const methods continue
 to require exclusive access.


 Note that implementations may choose not to check required fields within
 a lazy sub-message.  That is, calling IsInitialized() on the outer message
 may return true even if the inner message has missing required fields.
 This is necessary because otherwise the inner message would have to be
 parsed in order to perform the check, defeating the purpose of lazy
 parsing.  An implementation which chooses not to check required fields
 must be consistent about it.  That is, for any particular sub-message, the
 implementation must either *always* check its required fields, or *never*
 check its required fields, regardless of whether or not the message has
 been parsed.


�


�

�

�

�*

�$)
�
�1� Is this field deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for accessors, or it will be completely ignored; in the very least, this
 is a formalization for deprecating fields.


�


�

�

�

�0

�*/
?
�,1 For Google-internal migration only. Do not use.


�


�

�

�

�+

�%*
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

	�" removed jtype


	 �

	 �

	 �

� �

�
O
 �:A The parser stores options it doesn't recognize here. See above.


 �


 �

 �3

 �69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

� �

�
`
 � R Set this option to true to allow mapping different tag names to the same
 value.


 �


 �

 �

 �
�
�1� Is this enum deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for the enum, or it will be completely ignored; in the very least, this
 is a formalization for deprecating enums.


�


�

�

�

�0

�*/

	�" javanano_as_lite


	 �

	 �

	 �
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

� �

�
�
 �1� Is this enum value deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for the enum value, or it will be completely ignored; in the very least,
 this is a formalization for deprecating enum values.


 �


 �

 �

 �

 �0

 �*/
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

� �

�
�
 �2� Is this service deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for the service, or it will be completely ignored; in the very least,
 this is a formalization for deprecating services.
2� Note:  Field numbers 1 through 32 are reserved for Google's internal RPC
   framework.  We apologize for hoarding these numbers to ourselves, but
   we were already using them long before we decided to release Protocol
   Buffers.


 �


 �

 �

 �

 � 1

 �+0
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

� �

�
�
 �2� Is this method deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for the method, or it will be completely ignored; in the very least,
 this is a formalization for deprecating methods.
2� Note:  Field numbers 1 through 32 are reserved for Google's internal RPC
   framework.  We apologize for hoarding these numbers to ourselves, but
   we were already using them long before we decided to release Protocol
   Buffers.


 �


 �

 �

 �

 � 1

 �+0
�
 ��� Is this method side-effect-free (or safe in HTTP parlance), or idempotent,
 or neither? HTTP based RPC implementation may choose GET verb for safe
 methods, and PUT verb for idempotent methods instead of the default POST.


 �

  �

  �

  �
$
 �" implies idempotent


 �

 �
7
 �"' idempotent, but may have side effects


 �

 �

��&

�


�

�-

�02

�%

�$
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �
�
� �� A message representing a option the parser does not recognize. This only
 appears in options protos created by the compiler::Parser class.
 DescriptorPool resolves these when building Descriptor objects. Therefore,
 options protos in descriptor objects (e.g. returned by Descriptor::options(),
 or produced by Descriptor::CopyTo()) will never have UninterpretedOptions
 in them.


�
�
 ��� The name of the uninterpreted option.  Each string represents a segment in
 a dot-separated name.  is_extension is true iff a segment represents an
 extension (denoted with parentheses in options specs in .proto files).
 E.g.,{ ["foo", false], ["bar.baz", true], ["qux", false] } represents
 "foo.(bar.baz).qux".


 �


  �"

  �

  �

  �

  � !

 �#

 �

 �

 �

 �!"

 �

 �


 �

 �

 �
�
�'� The value of the uninterpreted option, in whatever type the tokenizer
 identified it as during parsing. Exactly one of these should be set.


�


�

�"

�%&

�)

�


�

�$

�'(

�(

�


�

�#

�&'

�#

�


�

�

�!"

�"

�


�

�

� !

�&

�


�

�!

�$%
�
� �j Encapsulates information about the original source file from which a
 FileDescriptorProto was generated.
2` ===================================================================
 Optional source code info


�
�
 �!� A Location identifies a piece of source code in a .proto file which
 corresponds to a particular definition.  This information is intended
 to be useful to IDEs, code indexers, documentation generators, and similar
 tools.

 For example, say we have a file like:
   message Foo {
     optional string foo = 1;
   }
 Let's look at just the field definition:
   optional string foo = 1;
   ^       ^^     ^^  ^  ^^^
   a       bc     de  f  ghi
 We have the following locations:
   span   path               represents
   [a,i)  [ 4, 0, 2, 0 ]     The whole field definition.
   [a,b)  [ 4, 0, 2, 0, 4 ]  The label (optional).
   [c,d)  [ 4, 0, 2, 0, 5 ]  The type (string).
   [e,f)  [ 4, 0, 2, 0, 1 ]  The name (foo).
   [g,h)  [ 4, 0, 2, 0, 3 ]  The number (1).

 Notes:
 - A location may refer to a repeated field itself (i.e. not to any
   particular index within it).  This is used whenever a set of elements are
   logically enclosed in a single code segment.  For example, an entire
   extend block (possibly containing multiple extension definitions) will
   have an outer location whose path refers to the "extensions" repeated
   field without an index.
 - Multiple locations may have the same path.  This happens when a single
   logical declaration is spread out across multiple places.  The most
   obvious example is the "extend" block again -- there may be multiple
   extend blocks in the same scope, each of which will have the same path.
 - A location's span is not always a subset of its parent's span.  For
   example, the "extendee" of an extension declaration appears at the
   beginning of the "extend" block and is shared by all extensions within
   the block.
 - Just because a location's span is a subset of some other location's span
   does not mean that it is a descendant.  For example, a "group" defines
   both a type and a field in a single declaration.  Thus, the locations
   corresponding to the type and field and their components will overlap.
 - Code which tries to interpret locations should probably be designed to
   ignore those that it doesn't understand, as more types of locations could
   be recorded in the future.


 �


 �

 �

 � 

 ��

 �

�
  �,� Identifies which part of the FileDescriptorProto was defined at this
 location.

 Each element is a field number or an index.  They form a path from
 the root FileDescriptorProto to the place where the definition.  For
 example, this path:
   [ 4, 3, 2, 7, 1 ]
 refers to:
   file.message_type(3)  // 4, 3
       .field(7)         // 2, 7
       .name()           // 1
 This is because FileDescriptorProto.message_type has field number 4:
   repeated DescriptorProto message_type = 4;
 and DescriptorProto.field has field number 2:
   repeated FieldDescriptorProto field = 2;
 and FieldDescriptorProto.name has field number 1:
   optional string name = 1;

 Thus, the above path gives the location of a field name.  If we removed
 the last element:
   [ 4, 3, 2, 7 ]
 this path refers to the whole field declaration (from the beginning
 of the label to the terminating semicolon).


  �

  �

  �

  �

  �+

  �*
�
 �,� Always has exactly three or four elements: start line, start column,
 end line (optional, otherwise assumed same as start line), end column.
 These are packed into a single field for efficiency.  Note that line
 and column numbers are zero-based -- typically you will want to add
 1 to each before displaying to a user.


 �

 �

 �

 �

 �+

 �*
�
 �)� If this SourceCodeInfo represents a complete declaration, these are any
 comments appearing before and after the declaration which appear to be
 attached to the declaration.

 A series of line comments appearing on consecutive lines, with no other
 tokens appearing on those lines, will be treated as a single comment.

 leading_detached_comments will keep paragraphs of comments that appear
 before (but not connected to) the current element. Each paragraph,
 separated by empty lines, will be one comment element in the repeated
 field.

 Only the comment content is provided; comment markers (e.g. //) are
 stripped out.  For block comments, leading whitespace and an asterisk
 will be stripped from the beginning of each line other than the first.
 Newlines are included in the output.

 Examples:

   optional int32 foo = 1;  // Comment attached to foo.
   // Comment attached to bar.
   optional int32 bar = 2;

   optional string baz = 3;
   // Comment attached to baz.
   // Another line attached to baz.

   // Comment attached to qux.
   //
   // Another line attached to qux.
   optional double qux = 4;

   // Detached comment for corge. This is not leading or trailing comments
   // to qux or corge because there are blank lines separating it from
   // both.

   // Detached comment for corge paragraph 2.

   optional string corge = 5;
   /* Block comment attached
    * to corge.  Leading asterisks
    * will be removed. */
   /* Block comment attached to
    * grault. */
   optional int32 grault = 6;

   // ignored detached comments.


 �

 �

 �$

 �'(

 �*

 �

 �

 �%

 �()

 �2

 �

 �

 �-

 �01
�
� �� Describes the relationship between generated code and its original source
 file. A GeneratedCodeInfo message is associated with only one generated
 source file, but may contain references to different source .proto files.


�
x
 �%j An Annotation connects some span of text in generated code to an element
 of its generating .proto file.


 �


 �

 � 

 �#$

 ��

 �

�
  �, Identifies the element in the original source .proto file. This field
 is formatted the same as SourceCodeInfo.Location.path.


  �

  �

  �

  �

  �+

  �*
O
 �$? Identifies the filesystem path to the original source .proto.


 �

 �

 �

 �"#
w
 �g Identifies the starting offset in bytes in the generated code
 that relates to the identified object.


 �

 �

 �

 �
�
 �� Identifies the ending offset in bytes in the generated code that
 relates to the identified offset. The end offset should be one past
 the last relevant byte (so the length of the text = end - begin).


 �

 �

 �

 �
�
google/api/annotations.proto
google.apigoogle/api/http.proto google/protobuf/descriptor.proto:K
http.google.protobuf.MethodOptions�ʼ" (2.google.api.HttpRuleRhttpBn
com.google.apiBAnnotationsProtoPZAgoogle.golang.org/genproto/googleapis/api/annotations;annotations�GAPIJ�
 
�
 2� Copyright (c) 2015, Google Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
  
	
 *

 X
	
 X

 "
	

 "

 1
	
 1

 '
	
 '

 "
	
$ "
	
 

  See `HttpRule`.



 $


 



 


 bproto3
�U
TenantProfileService.proto(org.apache.custos.tenant.profile.service"�	
Tenant
	tenant_id (RtenantId
client_name (	R
clientName'
requester_email (	RrequesterEmail(
admin_first_name (	RadminFirstName&
admin_last_name (	RadminLastName
admin_email (	R
adminEmail%
admin_username (	RadminUsername%
admin_password	 (	RadminPassword[
tenant_status
 (26.org.apache.custos.tenant.profile.service.TenantStatusRtenantStatus
contacts (	Rcontacts#
redirect_uris (	RredirectUris

client_uri (	R	clientUri
scope (	Rscope
domain (	Rdomain
comment (	Rcomment
logo_uri (	RlogoUri(
parent_tenant_id (RparentTenantId)
application_type (	RapplicationType;
token_endpoint_auth_method (	RtokenEndpointAuthMethod
jwks_uri (	RjwksUri>
example_extension_parameter (	RexampleExtensionParameter
tos_uri (	RtosUri

policy_uri (	R	policyUriN
jwks (2:.org.apache.custos.tenant.profile.service.Tenant.JwksEntryRjwks
software_id (	R
softwareId)
software_version (	RsoftwareVersion2
refesh_token_lifetime (RrefeshTokenLifetime
	client_id (	RclientId(
parent_client_id (	RparentClientId7
	JwksEntry
key (	Rkey
value (	Rvalue:8"�
TenantAttributeUpdateMetadata+
updated_attribute (	RupdatedAttribute5
updated_attributeValue (	RupdatedAttributeValue

updated_by (	R	updatedBy

updated_at (	R	updatedAt"�
TenantStatusUpdateMetadata]
updated_status (26.org.apache.custos.tenant.profile.service.TenantStatusRupdatedStatus

updated_by (	R	updatedBy

updated_at (	R	updatedAt"0
AddTenantResponse
	tenant_id (RtenantId"`
UpdateTenantResponseH
tenant (20.org.apache.custos.tenant.profile.service.TenantRtenant"/
GetTenantRequest
	tenant_id (RtenantId"]
GetTenantResponseH
tenant (20.org.apache.custos.tenant.profile.service.TenantRtenant"�
GetAllTenantsResponseH
tenant (20.org.apache.custos.tenant.profile.service.TenantRtenant/
total_num_of_tenants (RtotalNumOfTenants"3
IsTenantExistRequest
	tenant_id (RtenantId"2
IsTenantExistResponse
is_exist (RisExist"F
GetAllTenantsForUserRequest'
requester_email (	RrequesterEmail"h
GetAllTenantsForUserResponseH
tenant (20.org.apache.custos.tenant.profile.service.TenantRtenant"�
UpdateStatusRequest
	client_id (	RclientIdN
status (26.org.apache.custos.tenant.profile.service.TenantStatusRstatus

updated_by (	R	updatedBy
	tenant_id (RtenantId!
super_tenant (RsuperTenant!
access_token (	RaccessToken"�
UpdateStatusResponse
	tenant_id (RtenantIdN
status (26.org.apache.custos.tenant.profile.service.TenantStatusRstatus"3
GetAuditTrailRequest
	tenant_id (RtenantId"�
!GetStatusUpdateAuditTrailResponse`
metadata (2D.org.apache.custos.tenant.profile.service.TenantStatusUpdateMetadataRmetadata"�
$GetAttributeUpdateAuditTrailResponsec
metadata (2G.org.apache.custos.tenant.profile.service.TenantAttributeUpdateMetadataRmetadata"�
GetTenantsRequest
offset (Roffset
limit (Rlimit
	parent_id (RparentIdN
status (26.org.apache.custos.tenant.profile.service.TenantStatusRstatus'
requester_email (	RrequesterEmail(
parent_client_id (	RparentClientIdH
type (24.org.apache.custos.tenant.profile.service.TenantTypeRtype*p
TenantStatus
UNKNOWN 
	REQUESTED
APPROVED

DENIED
	CANCELLED

ACTIVE
DEACTIVATED*(

TenantType
UNSPECIFIED 	
ADMIN2�

TenantProfileServiceo
	addTenant0.org.apache.custos.tenant.profile.service.Tenant0.org.apache.custos.tenant.profile.service.Tenantr
updateTenant0.org.apache.custos.tenant.profile.service.Tenant0.org.apache.custos.tenant.profile.service.Tenant�
	getTenant:.org.apache.custos.tenant.profile.service.GetTenantRequest;.org.apache.custos.tenant.profile.service.GetTenantResponse�
updateTenantStatus=.org.apache.custos.tenant.profile.service.UpdateStatusRequest>.org.apache.custos.tenant.profile.service.UpdateStatusResponse�
getAllTenants;.org.apache.custos.tenant.profile.service.GetTenantsRequest?.org.apache.custos.tenant.profile.service.GetAllTenantsResponse�
isTenantExist>.org.apache.custos.tenant.profile.service.IsTenantExistRequest?.org.apache.custos.tenant.profile.service.IsTenantExistResponse�
getAllTenantsForUserE.org.apache.custos.tenant.profile.service.GetAllTenantsForUserRequestF.org.apache.custos.tenant.profile.service.GetAllTenantsForUserResponse�
getTenantStatusUpdateAuditTrail>.org.apache.custos.tenant.profile.service.GetAuditTrailRequestK.org.apache.custos.tenant.profile.service.GetStatusUpdateAuditTrailResponse�
"getTenantAttributeUpdateAuditTrail>.org.apache.custos.tenant.profile.service.GetAuditTrailRequestN.org.apache.custos.tenant.profile.service.GetAttributeUpdateAuditTrailResponseBPZ./pbJ�.
 �
�
 2�
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements. See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership. The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License. You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied. See the License for the
 specific language governing permissions and limitations
 under the License.



 "
	

 "

 1

 
	
 


  8


 

  

  	

  


  

 

 


 

 

 

 


 

 

  

 


 

 

 

 


 

 

  

  


  

  

 !

 !


 !

 !

 "

 "


 "

 "

 #$

 #

 #

 #!#

 	$"

 	$

 	$

 	$

 	$!

 
%'

 
%

 
%

 
%!

 
%$&

 &

 &


 &

 &

 '

 '


 '

 '

 (

 (


 (

 (

 )

 )


 )

 )

 *

 *


 *

 *

 + 

 +	

 +


 +

 ,!

 ,


 ,

 , 

 -+

 -


 -%

 -(*

 .

 .


 .

 .

 /,

 /


 /&

 /)+

 0

 0


 0

 0

 1

 1


 1

 1

 2"

 2

 2

 2!

 3

 3


 3

 3

 4!

 4


 4

 4 

 5%

 5	

 5


 5"$

 6

 6


 6

 6

 7!

 7


 7

 7 


 : B


 :

  ;

  ;

  ;

 <

 <

 <

 =

 =

 =

 >

 >


 >

 ?

 ?

 ?

 @

 @


 @

 A

 A

 A


D G


D

 E

 E

 E

F

F	

F


I N


I%

 J!

 J


 J

 J 

K&

K


K!

K$%

L

L


L

L

M

M


M

M


P T


P"

 Q$

 Q

 Q

 Q"#

R

R


R

R

S

S


S

S


W Y


W

 X

 X	

 X


 X


\ _


\

 ]

 ]


 ]

 ]


a c


a

 b

 b	

 b


 b


e g


e

 f

 f


 f

 f


j m


j

 k

 k

 k

 k

 k

l"

l	

l


l !


o q


o

 p

 p	

 p


 p


	s u


	s

	 t

	 t

	 t	

	 t



w y



w#


 x


 x



 x


 x


{ }


{$

 |

 |

 |

 |

 |

 �




 �

 �


 �

 �

�

�

�

�

�

�


�

�

�

�	

�


�

�

�

�	

�

�

�


�

�

� �

�

 �

 �	

 �


 �

�

�

�

�

� �

�

 �

 �	

 �


 �

� �

�)

 �5

 �

 �'

 �(0

 �34

� �

�,

 �8

 �

 �*

 �+3

 �67

� �

�

 �

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

�

 � �

 �

  �,

  �

  �

  �$*

 �/

 �

 �

 �'-

 �A

 �

 �#

 �.?

 �P

 �

 �/

 �:N

 �J

 �

 �(

 �3H

 �M

 �

 �+

 �6K

 �b

 �

 �9

 �D`

 �k

 �'

 �)=

 �Hi

 �q

 �*

 �,@

 �Kobproto3
�%
google/protobuf/duration.protogoogle.protobuf":
Duration
seconds (Rseconds
nanos (RnanosB|
com.google.protobufBDurationProtoPZ*github.com/golang/protobuf/ptypes/duration��GPB�Google.Protobuf.WellKnownTypesJ�#
 s
�
 2� Protocol Buffers - Google's data interchange format
 Copyright 2008 Google Inc.  All rights reserved.
 https://developers.google.com/protocol-buffers/

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

     * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following disclaimer
 in the documentation and/or other materials provided with the
 distribution.
     * Neither the name of Google Inc. nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


  

" ;
	
%" ;

# 
	
# 

$ A
	
$ A

% ,
	
% ,

& .
	
& .

' "
	

' "

( !
	
$( !
�
 f s� A Duration represents a signed, fixed-length span of time represented
 as a count of seconds and fractions of seconds at nanosecond
 resolution. It is independent of any calendar and concepts like "day"
 or "month". It is related to Timestamp in that the difference between
 two Timestamp values is a Duration and it can be added or subtracted
 from a Timestamp. Range is approximately +-10,000 years.

 # Examples

 Example 1: Compute Duration from two Timestamps in pseudo code.

     Timestamp start = ...;
     Timestamp end = ...;
     Duration duration = ...;

     duration.seconds = end.seconds - start.seconds;
     duration.nanos = end.nanos - start.nanos;

     if (duration.seconds < 0 && duration.nanos > 0) {
       duration.seconds += 1;
       duration.nanos -= 1000000000;
     } else if (duration.seconds > 0 && duration.nanos < 0) {
       duration.seconds -= 1;
       duration.nanos += 1000000000;
     }

 Example 2: Compute Timestamp from Timestamp + Duration in pseudo code.

     Timestamp start = ...;
     Duration duration = ...;
     Timestamp end = ...;

     end.seconds = start.seconds + duration.seconds;
     end.nanos = start.nanos + duration.nanos;

     if (end.nanos < 0) {
       end.seconds -= 1;
       end.nanos += 1000000000;
     } else if (end.nanos >= 1000000000) {
       end.seconds += 1;
       end.nanos -= 1000000000;
     }

 Example 3: Compute Duration from datetime.timedelta in Python.

     td = datetime.timedelta(days=3, minutes=10)
     duration = Duration()
     duration.FromTimedelta(td)

 # JSON Mapping

 In JSON format, the Duration type is encoded as a string rather than an
 object, where the string ends in the suffix "s" (indicating seconds) and
 is preceded by the number of seconds, with nanoseconds expressed as
 fractional seconds. For example, 3 seconds with 0 nanoseconds should be
 encoded in JSON format as "3s", while 3 seconds and 1 nanosecond should
 be expressed in JSON format as "3.000000001s", and 3 seconds and 1
 microsecond should be expressed in JSON format as "3.000001s".





 f
�
  j� Signed seconds of the span of time. Must be from -315,576,000,000
 to +315,576,000,000 inclusive. Note: these bounds are computed from:
 60 sec/min * 60 min/hr * 24 hr/day * 365.25 days/year * 10000 years


  j

  j

  j
�
 r� Signed fractions of a second at nanosecond resolution of the span
 of time. Durations less than one second are represented with a 0
 `seconds` field and a positive or negative `nanos` field. For durations
 of one second or more, a non-zero value for the `nanos` field must be
 of the same sign as the `seconds` field. Must be from -999,999,999
 to +999,999,999 inclusive.


 r

 r

 rbproto3
�G
google/rpc/error_details.proto
google.rpcgoogle/protobuf/duration.proto"G
	RetryInfo:
retry_delay (2.google.protobuf.DurationR
retryDelay"H
	DebugInfo#
stack_entries (	RstackEntries
detail (	Rdetail"�
QuotaFailureB

violations (2".google.rpc.QuotaFailure.ViolationR
violationsG
	Violation
subject (	Rsubject 
description (	Rdescription"�
PreconditionFailureI

violations (2).google.rpc.PreconditionFailure.ViolationR
violations[
	Violation
type (	Rtype
subject (	Rsubject 
description (	Rdescription"�

BadRequestP
field_violations (2%.google.rpc.BadRequest.FieldViolationRfieldViolationsH
FieldViolation
field (	Rfield 
description (	Rdescription"O
RequestInfo

request_id (	R	requestId!
serving_data (	RservingData"�
ResourceInfo#
resource_type (	RresourceType#
resource_name (	RresourceName
owner (	Rowner 
description (	Rdescription"o
Help+
links (2.google.rpc.Help.LinkRlinks:
Link 
description (	Rdescription
url (	Rurl"D
LocalizedMessage
locale (	Rlocale
message (	RmessageBl
com.google.rpcBErrorDetailsProtoPZ?google.golang.org/genproto/googleapis/rpc/errdetails;errdetails�RPCJ�>
 �
�
 2� Copyright 2017 Google Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.


 
	
  (

 V
	
 V

 "
	

 "

 2
	
 2

 '
	
 '

 !
	
$ !
�
 ' *� Describes when the clients can retry a failed request. Clients could ignore
 the recommendation here or retry when this information is missing from error
 responses.

 It's always recommended that clients should use exponential backoff when
 retrying.

 Clients should wait until `retry_delay` amount of time has passed since
 receiving the error response before retrying.  If retrying requests also
 fail, clients should use an exponential backoff scheme to gradually increase
 the delay between retries based on `retry_delay`, until either a maximum
 number of retires have been reached or a maximum retry delay cap has been
 reached.



 '
X
  )+K Clients should wait at least this long between retrying the same request.


  )

  )&

  ))*
2
- 3& Describes additional debugging info.



-
K
 /$> The stack trace entries indicating where the error occurred.


 /


 /

 /

 /"#
G
2: Additional debugging information provided by the server.


2

2	

2
�
@ U� Describes how a quota check failed.

 For example if a daily limit was exceeded for the calling project,
 a service could respond with a QuotaFailure detail containing the project
 id and the description of the quota limit that was exceeded.  If the
 calling project hasn't enabled the service in the developer console, then
 a service could respond with the project id and set `service_disabled`
 to true.

 Also see RetryDetail and Help types for other details about handling a
 quota failure.



@
�
 CQ} A message type used to describe a single quota violation.  For example, a
 daily quota or a custom quota that was exceeded.


 C

�
  G� The subject on which the quota check failed.
 For example, "clientip:<ip address of client>" or "project:<Google
 developer project id>".


  G


  G

  G
�
 P� A description of how the quota check failed. Clients can use this
 description to find more about the quota configuration in the service's
 public documentation, or find the relevant quota limit to adjust through
 developer console.

 For example: "Service disabled" or "Daily Limit for read operations
 exceeded".


 P


 P

 P
.
 T$! Describes all quota violations.


 T


 T

 T

 T"#
�
\ r� Describes what preconditions have failed.

 For example, if an RPC failed because it required the Terms of Service to be
 acknowledged, it could list the terms of service violation in the
 PreconditionFailure message.



\
N
 ^n@ A message type used to describe a single precondition failure.


 ^

�
  b� The type of PreconditionFailure. We recommend using a service-specific
 enum type to define the supported precondition violation types. For
 example, "TOS" for "Terms of Service violation".


  b


  b

  b
�
 g� The subject, relative to the type, that failed.
 For example, "google.com/cloud" relative to the "TOS" type would
 indicate which terms of service is being referenced.


 g


 g

 g
�
 m� A description of how the precondition failed. Developers can use this
 description to understand how to fix the failure.

 For example: "Terms of service not accepted".


 m


 m

 m
5
 q$( Describes all precondition violations.


 q


 q

 q

 q"#
z
v �m Describes violations in a client request. This error type focuses on the
 syntactic aspects of the request.



v
L
 x�= A message type used to describe a single bad request field.


 x

�
  |� A path leading to a field in the request body. The value will be a
 sequence of dot-separated identifiers that identify a protocol buffer
 field. E.g., "field_violations.field" would identify this field.


  |


  |

  |
A
 2 A description of why the request element is bad.


 


 

 
=
 �// Describes all violations in a client request.


 �


 �

 �*

 �-.
�
� �v Contains metadata about the request that clients can attach when filing a bug
 or providing other forms of feedback.


�
�
 �� An opaque string that should only be interpreted by the service generating
 it. For example, it can be used to identify requests in the service's logs.


 �

 �	

 �
�
�� Any data that was used to serve this request. For example, an encrypted
 stack trace that can be sent back to the service provider for debugging.


�

�	

�
>
� �0 Describes the resource that is being accessed.


�
�
 �� A name for the type of resource being accessed, e.g. "sql table",
 "cloud storage bucket", "file", "Google calendar"; or the type URL
 of the resource: e.g. "type.googleapis.com/google.pubsub.v1.Topic".


 �

 �	

 �
�
�� The name of the resource being accessed.  For example, a shared calendar
 name: "example.com_4fghdhgsrgh@group.calendar.google.com", if the current
 error is
 [google.rpc.Code.PERMISSION_DENIED][google.rpc.Code.PERMISSION_DENIED].


�

�	

�
�
�w The owner of the resource (optional).
 For example, "user:<owner email>" or "project:<Google developer project
 id>".


�

�	

�
�
�� Describes what error is encountered when accessing this resource.
 For example, updating a cloud project may require the `writer` permission
 on the developer console project.


�

�	

�
�
� �� Provides links to documentation or for performing an out of band action.

 For example, if a quota check failed with an error indicating the calling
 project hasn't enabled the accessed service, this can contain a URL pointing
 directly to the right place in the developer console to flip the bit.


�
'
 �� Describes a URL link.


 �

1
  �! Describes what the link offers.


  �


  �

  �
&
 � The URL of the link.


 �


 �

 �
X
 �J URL(s) pointing to additional information on handling the current error.


 �


 �

 �

 �
}
� �o Provides a localized error message that is safe to return to the user
 which can be attached to an RPC error.


�
�
 �� The locale used following the specification defined at
 http://www.rfc-editor.org/rfc/bcp/bcp47.txt.
 Examples are: "en-US", "fr-CH", "es-MX"


 �

 �	

 �
@
�2 The localized error message in the above locale.


�

�	

�bproto3
�
google/protobuf/empty.protogoogle.protobuf"
EmptyBv
com.google.protobufB
EmptyProtoPZ'github.com/golang/protobuf/ptypes/empty��GPB�Google.Protobuf.WellKnownTypesJ�
 3
�
 2� Protocol Buffers - Google's data interchange format
 Copyright 2008 Google Inc.  All rights reserved.
 https://developers.google.com/protocol-buffers/

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

     * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following disclaimer
 in the documentation and/or other materials provided with the
 distribution.
     * Neither the name of Google Inc. nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


  

" ;
	
%" ;

# >
	
# >

$ ,
	
$ ,

% +
	
% +

& "
	

& "

' !
	
$' !

( 
	
( 
�
 3 � A generic empty message that you can re-use to avoid defining duplicated
 empty messages in your APIs. A typical example is to use it as the request
 or the response type of an API method. For instance:

     service Foo {
       rpc Bar(google.protobuf.Empty) returns (google.protobuf.Empty);
     }

 The JSON representation for `Empty` is empty JSON object `{}`.



 3bproto3
��
IamAdminService.protoorg.apache.custos.iam.servicegoogle/protobuf/empty.proto"�
SetUpTenantRequest
	tenant_id (RtenantId
tenant_name (	R
tenantName%
admin_username (	RadminUsername'
admin_firstname (	RadminFirstname%
admin_lastname (	RadminLastname
admin_email (	R
adminEmail%
admin_password (	RadminPassword

tenant_uRL (	R	tenantURL'
requester_email	 (	RrequesterEmail#
redirect_uRIs
 (	RredirectURIs(
custos_client_id (	RcustosClientId"�
ConfigureFederateIDPRequest
	tenant_id (RtenantId@
type (2,.org.apache.custos.iam.service.FederatedIDPsRtype
	client_iD (	RclientID

client_sec (	R	clientSech

config_map (2I.org.apache.custos.iam.service.ConfigureFederateIDPRequest.ConfigMapEntryR	configMap'
requester_email (	RrequesterEmail
idp_id (	RidpId
scope (	Rscope<
ConfigMapEntry
key (	Rkey
value (	Rvalue:8"-
FederateIDPResponse
status (Rstatus"W
SetUpTenantResponse
	client_id (	RclientId#
client_secret (	RclientSecret"y
IsUsernameAvailableRequest
	tenant_id (RtenantId!
access_token (	RaccessToken
	user_name (	RuserName"-
CheckingResponse
is_exist (RisExist"�
UserRepresentation
id (	Rid
username (	Rusername

first_name (	R	firstName
	last_name (	RlastName
password (	Rpassword
email (	Remail-
temporary_password (RtemporaryPassword
realm_roles	 (	R
realmRoles!
client_roles
 (	RclientRolesL

attributes (2,.org.apache.custos.iam.service.UserAttributeR
attributes
state (	Rstate#
creation_time (RcreationTime"
last_login_at (RlastLoginAt"�
GroupRepresentation
name (	Rname
id (	Rid
realm_roles (	R
realmRoles!
client_roles (	RclientRolesL

attributes (2,.org.apache.custos.iam.service.UserAttributeR
attributesG
users (21.org.apache.custos.iam.service.UserRepresentationRusersQ

sub_groups (22.org.apache.custos.iam.service.GroupRepresentationR	subGroups 
description (	Rdescription
ownerId	 (	RownerId"�
RegisterUserRequest
	tenant_id (RtenantId!
access_token (	RaccessToken
	client_id (	RclientId

client_sec (	R	clientSecE
user (21.org.apache.custos.iam.service.UserRepresentationRuser!
performed_by (	RperformedBy"�
RegisterUsersRequestG
users (21.org.apache.custos.iam.service.UserRepresentationRusers
	tenant_id (RtenantId!
access_token (	RaccessToken
	client_id (	RclientId!
performed_by (	RperformedBy";
RegisterUserResponse#
is_registered (RisRegistered"�
RegisterUsersResponse2
all_useres_registered (RallUseresRegisteredT
failed_users (21.org.apache.custos.iam.service.UserRepresentationRfailedUsers"�
UserSearchMetadata
username (	Rusername

first_name (	R	firstName
	last_name (	RlastName
email (	Remail
id (	Rid"�
FindUsersRequestE
user (21.org.apache.custos.iam.service.UserSearchMetadataRuser
offset (Roffset
limit (Rlimit
	tenant_id (RtenantId!
access_token (	RaccessToken
	client_id (	RclientId

client_sec (	R	clientSec"�
UserSearchRequestE
user (21.org.apache.custos.iam.service.UserSearchMetadataRuser
	tenant_id (RtenantId!
access_token (	RaccessToken
	client_id (	RclientId

client_sec (	R	clientSec!
performed_by (	RperformedBy"\
FindUsersResponseG
users (21.org.apache.custos.iam.service.UserRepresentationRusers"�
ResetUserPassword
username (	Rusername
password (	Rpassword
	tenant_id (RtenantId!
access_token (	RaccessToken
	client_id (	RclientId

client_sec (	R	clientSec"�
DeleteUserRolesRequest
	tenant_id (RtenantId
username (	Rusername!
client_roles (	RclientRoles
roles (	Rroles!
access_token (	RaccessToken
	client_id (	RclientId!
performed_by (	RperformedBy
id (	Rid"�
AddUserRolesRequest
	tenant_id (RtenantId
	usernames (	R	usernames
roles (	Rroles!
access_token (	RaccessToken
	client_id (	RclientId!
client_level (RclientLevel!
performed_by (	RperformedBy
agents (	Ragents"�
UpdateUserProfileRequest!
access_token (	RaccessToken
	tenant_id (RtenantIdE
user (21.org.apache.custos.iam.service.UserRepresentationRuser"%
AddUserResponse
code (	Rcode"9
GetOperationsMetadataRequest
trace_id (RtraceId"�
OperationMetadata
event (	Revent
status (	Rstatus

time_stamp (	R	timeStamp!
performed_by (	RperformedBy"m
GetOperationsMetadataResponseL
metadata (20.org.apache.custos.iam.service.OperationMetadataRmetadata"2
DeleteTenantRequest
	tenant_id (RtenantId"�
AddRolesRequestG
roles (21.org.apache.custos.iam.service.RoleRepresentationRroles!
client_level (RclientLevel
	tenant_id (RtenantId
	client_id (	RclientId"n
GetRolesRequest!
client_level (RclientLevel
	tenant_id (RtenantId
	client_id (	RclientId"x
RoleRepresentation
name (	Rname 
description (	Rdescription
	composite (R	composite
id (	Rid"�
DeleteRoleRequest!
client_level (RclientLevel
	tenant_id (RtenantId
	client_id (	RclientIdE
role (21.org.apache.custos.iam.service.RoleRepresentationRrole"i
AllRolesG
roles (21.org.apache.custos.iam.service.RoleRepresentationRroles
scope (	Rscope"�
AddProtocolMapperRequest
name (	Rname%
attribute_name (	RattributeName

claim_name (	R	claimNameL

claim_type (2-.org.apache.custos.iam.service.ClaimJSONTypesR	claimType
	tenant_id (RtenantId
	client_id (	RclientIdK
mapper_type (2*.org.apache.custos.iam.service.MapperTypesR
mapperType%
add_to_id_token	 (RaddToIdToken-
add_to_access_token
 (RaddToAccessToken'
add_to_user_info (RaddToUserInfo!
multi_valued (RmultiValued<
aggregate_attribute_values (RaggregateAttributeValues")
OperationStatus
status (Rstatus"�
AddUserAttributesRequestL

attributes (2,.org.apache.custos.iam.service.UserAttributeR
attributes
users (	Rusers
	tenant_id (RtenantId
	client_id (	RclientId!
access_token (	RaccessToken 
performedBy (	RperformedBy
agents (	Ragents"�
DeleteUserAttributeRequestL

attributes (2,.org.apache.custos.iam.service.UserAttributeR
attributes
users (	Rusers
	tenant_id (RtenantId
	client_id (	RclientId!
access_token (	RaccessToken 
performedBy (	RperformedBy
agents (	Ragents"9
UserAttribute
key (	Rkey
values (	Rvalues"�
EventPersistenceRequest
tenantId (RtenantId
admin_event (R
adminEvent
event (	Revent
enable (Renable)
persistence_time (RpersistenceTime 
performedBy (	RperformedBy"�
GroupsRequest
tenantId (RtenantId 
accessToken (	RaccessToken 
performedBy (	RperformedBy
clientId (	RclientId
	clientSec (	R	clientSecJ
groups (22.org.apache.custos.iam.service.GroupRepresentationRgroups"�
GroupRequest
tenantId (RtenantId 
accessToken (	RaccessToken 
performedBy (	RperformedBy
clientId (	RclientId
	clientSec (	R	clientSec
id (	RidH
group (22.org.apache.custos.iam.service.GroupRepresentationRgroup"\
GroupsResponseJ
groups (22.org.apache.custos.iam.service.GroupRepresentationRgroups"�
UserGroupMappingRequest
tenantId (RtenantId 
accessToken (	RaccessToken 
performedBy (	RperformedBy
clientId (	RclientId
	clientSec (	R	clientSec
username (	Rusername
group_id (	RgroupId'
membership_type (	RmembershipType"�
AgentClientMetadata
tenantId (RtenantId
	tenantURL (	R	tenantURL"
redirectURIs (	RredirectURIs

clientName (	R
clientName3
access_token_life_time (RaccessTokenLifeTime 
performedBy (	RperformedBy!
access_token (	RaccessToken"�
Agent
id (	Rid
realm_roles (	R
realmRolesL

attributes (2,.org.apache.custos.iam.service.UserAttributeR
attributes
	isEnabled (R	isEnabled#
creation_time (RcreationTime(
last_modified_at (RlastModifiedAt!
client_roles (	RclientRoles"�
GetAllResources
tenantId (RtenantId
clientId (	RclientIdQ
resource_type (2,.org.apache.custos.iam.service.ResourceTypesRresourceType"�
GetAllResourcesResponse<
agents (2$.org.apache.custos.iam.service.AgentRagentsG
users (21.org.apache.custos.iam.service.UserRepresentationRusers"n
DeleteExternalIDPsRequest
	tenant_id (RtenantId
	client_id (	RclientId
user_id (	RuserId*b
FederatedIDPs
CILOGON 
FACEBOOK

GOOGLE
LINKEDIN
TWITTER
CUSTOM_OIDC*L
MapperTypes
USER_ATTRIBUTE 
USER_REALM_ROLE
USER_CLIENT_ROLE*J
ClaimJSONTypes

STRING 
LONG
INTEGER
BOOLEAN
JSON*$
ResourceTypes
USER 	
AGENT2�-
IamAdminServicet
setUPTenant1.org.apache.custos.iam.service.SetUpTenantRequest2.org.apache.custos.iam.service.SetUpTenantResponseu
updateTenant1.org.apache.custos.iam.service.SetUpTenantRequest2.org.apache.custos.iam.service.SetUpTenantResponseZ
deleteTenant2.org.apache.custos.iam.service.DeleteTenantRequest.google.protobuf.Empty�
configureFederatedIDP:.org.apache.custos.iam.service.ConfigureFederateIDPRequest2.org.apache.custos.iam.service.FederateIDPResponsek
addRolesToTenant..org.apache.custos.iam.service.AddRolesRequest'.org.apache.custos.iam.service.AllRoles|
addProtocolMapper7.org.apache.custos.iam.service.AddProtocolMapperRequest..org.apache.custos.iam.service.OperationStatusk
getRolesOfTenant..org.apache.custos.iam.service.GetRolesRequest'.org.apache.custos.iam.service.AllRolesn

deleteRole0.org.apache.custos.iam.service.DeleteRoleRequest..org.apache.custos.iam.service.OperationStatusw
isUsernameAvailable0.org.apache.custos.iam.service.UserSearchRequest..org.apache.custos.iam.service.OperationStatusw
registerUser2.org.apache.custos.iam.service.RegisterUserRequest3.org.apache.custos.iam.service.RegisterUserResponseq

enableUser0.org.apache.custos.iam.service.UserSearchRequest1.org.apache.custos.iam.service.UserRepresentationr
disableUser0.org.apache.custos.iam.service.UserSearchRequest1.org.apache.custos.iam.service.UserRepresentationq
isUserEnabled0.org.apache.custos.iam.service.UserSearchRequest..org.apache.custos.iam.service.OperationStatusp
isUserExist0.org.apache.custos.iam.service.UserSearchRequest/.org.apache.custos.iam.service.CheckingResponsen
getUser0.org.apache.custos.iam.service.UserSearchRequest1.org.apache.custos.iam.service.UserRepresentationn
	findUsers/.org.apache.custos.iam.service.FindUsersRequest0.org.apache.custos.iam.service.FindUsersResponseq
resetPassword0.org.apache.custos.iam.service.ResetUserPassword..org.apache.custos.iam.service.OperationStatusw
grantAdminPrivilege0.org.apache.custos.iam.service.UserSearchRequest..org.apache.custos.iam.service.OperationStatusx
removeAdminPrivilege0.org.apache.custos.iam.service.UserSearchRequest..org.apache.custos.iam.service.OperationStatus�
deleteExternalIDPLinksOfUsers8.org.apache.custos.iam.service.DeleteExternalIDPsRequest..org.apache.custos.iam.service.OperationStatus�
registerAndEnableUsers3.org.apache.custos.iam.service.RegisterUsersRequest4.org.apache.custos.iam.service.RegisterUsersResponse|
addUserAttributes7.org.apache.custos.iam.service.AddUserAttributesRequest..org.apache.custos.iam.service.OperationStatus�
deleteUserAttributes9.org.apache.custos.iam.service.DeleteUserAttributeRequest..org.apache.custos.iam.service.OperationStatusu
addRolesToUsers2.org.apache.custos.iam.service.AddUserRolesRequest..org.apache.custos.iam.service.OperationStatusn

deleteUser0.org.apache.custos.iam.service.UserSearchRequest..org.apache.custos.iam.service.OperationStatus|
deleteRolesFromUser5.org.apache.custos.iam.service.DeleteUserRolesRequest..org.apache.custos.iam.service.OperationStatus|
updateUserProfile7.org.apache.custos.iam.service.UpdateUserProfileRequest..org.apache.custos.iam.service.OperationStatus�
getOperationMetadata;.org.apache.custos.iam.service.GetOperationsMetadataRequest<.org.apache.custos.iam.service.GetOperationsMetadataResponse�
configureEventPersistence6.org.apache.custos.iam.service.EventPersistenceRequest..org.apache.custos.iam.service.OperationStatusk
createGroups,.org.apache.custos.iam.service.GroupsRequest-.org.apache.custos.iam.service.GroupsResponsen
updateGroup+.org.apache.custos.iam.service.GroupRequest2.org.apache.custos.iam.service.GroupRepresentationj
deleteGroup+.org.apache.custos.iam.service.GroupRequest..org.apache.custos.iam.service.OperationStatusl
	findGroup+.org.apache.custos.iam.service.GroupRequest2.org.apache.custos.iam.service.GroupRepresentationj
getAllGroups+.org.apache.custos.iam.service.GroupRequest-.org.apache.custos.iam.service.GroupsResponsex
addUserToGroup6.org.apache.custos.iam.service.UserGroupMappingRequest..org.apache.custos.iam.service.OperationStatus}
removeUserFromGroup6.org.apache.custos.iam.service.UserGroupMappingRequest..org.apache.custos.iam.service.OperationStatus{
createAgentClient2.org.apache.custos.iam.service.AgentClientMetadata2.org.apache.custos.iam.service.SetUpTenantResponsez
configureAgentClient2.org.apache.custos.iam.service.AgentClientMetadata..org.apache.custos.iam.service.OperationStatusx
isAgentNameAvailable0.org.apache.custos.iam.service.UserSearchRequest..org.apache.custos.iam.service.OperationStatus�
registerAndEnableAgent2.org.apache.custos.iam.service.RegisterUserRequest3.org.apache.custos.iam.service.RegisterUserResponseo
deleteAgent0.org.apache.custos.iam.service.UserSearchRequest..org.apache.custos.iam.service.OperationStatusb
getAgent0.org.apache.custos.iam.service.UserSearchRequest$.org.apache.custos.iam.service.Agentp
disableAgent0.org.apache.custos.iam.service.UserSearchRequest..org.apache.custos.iam.service.OperationStatuso
enableAgent0.org.apache.custos.iam.service.UserSearchRequest..org.apache.custos.iam.service.OperationStatus}
addAgentAttributes7.org.apache.custos.iam.service.AddUserAttributesRequest..org.apache.custos.iam.service.OperationStatus�
deleteAgentAttributes9.org.apache.custos.iam.service.DeleteUserAttributeRequest..org.apache.custos.iam.service.OperationStatusu
addRolesToAgent2.org.apache.custos.iam.service.AddUserRolesRequest..org.apache.custos.iam.service.OperationStatusy
deleteAgentRoles5.org.apache.custos.iam.service.DeleteUserRolesRequest..org.apache.custos.iam.service.OperationStatusy
getAllResources..org.apache.custos.iam.service.GetAllResources6.org.apache.custos.iam.service.GetAllResourcesResponseBPZ./pbJ��
 �
�
 2�
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements. See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership. The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License. You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied. See the License for the
 specific language governing permissions and limitations
 under the License.



 "
	

 "

 &
	
  %

 
	
 


  #


 

  

  

  

 

 

 

 

 


 

  

  

  

 !

 !

 !

 "

 "

 "


 & 3


 &

  '

  '	

  '


  '

 (

 (


 (

 (

 )

 )


 )

 )

 *

 *


 *

 *

 +

 +


 +

 +

 ,

 ,


 ,

 ,

 -

 -


 -

 -

 .

 .


 .

 .

 /

 /


 /

 /

 	0'

 	0

 	0

 	0!

 	0$&

 
1!

 
1


 
1

 
1 


5 >


5#

 6

 6	

 6


 6

7

7

7

7

8

8


8

8

9

9


9

9

:'

:

:"

:%&

;

;


;

;

<

<


<

<

=

=


=

=


A C


A

 B

 B

 B	

 B


E H


E

 F

 F


 F

 F

G

G


G

G


J O


J"

 K

 K	

 K


 K

L

L


L

L

M

M


M

M


Q S


Q

 R

 R

 R	

 R


V d


V

 W

 W


 W

 W

X

X


X

X

Y

Y


Y

Y

Z

Z


Z

Z

[

[


[

[

\

\


\

\

] 

]

]	

]

^$

^

^

^

^"#

_&

_

_

_ 

_#%

	`+

	`

	`

	`%

	`(*


a


a



a


a

b

b


b

b

c

c


c

c


g q


g

 h

 h


 h

 h

i

i


i

i

j$

j

j

j

j"#

k%

k

k

k 

k#$

l*

l

l

l%

l()

m*

m

m

m %

m()

n0

n

n 

n!+

n./

o

o


o

o

p

p


p

p


t {


t

 u

 u	

 u


 u

v

v


v

v

w

w


w

w

x

x


x

x

y 

y

y

y

z

z


z

z

	~ �


	~

	 *

	 

	 

	  %

	 ()

	�

	�	

	�


	�

	�

	�


	�

	�

	�

	�


	�

	�

	�

	�


	�

	�


� �


�


 �


 �


 �	


 �

� �

�

 �#

 �

 �	

 �!"

�1

�

�

� ,

�/0

� �

�

 �

 �


 �

 �

�

�


�

�

�

�


�

�

�

�


�

�

�

�


�

�

� �

�

 � 

 �

 �

 �

�

�	

�


�

�

�	

�


�

�

�	

�


�

�

�


�

�

�

�


�

�

�

�


�

�

� �

�

 � 

 �

 �

 �

�

�	

�


�

�

�


�

�

�

�


�

�

�

�


�

�

�

�


�

�

� �

�

 �*

 �

 �

 � %

 �()

� �

�

 �

 �


 �

 �

�

�


�

�

�

�	

�


�

�

�


�

�

�

�


�

�

�

�


�

�

� �

�

 �

 �	

 �


 �

�

�


�

�

�%

�

�

� 

�#$

�

�

�

�

�

�

�


�

�

�

�


�

�

�

�


�

�

�

�


�

�

� �

�

 �

 �	

 �


 �

�"

�

�

�

� !

�

�

�

�

�

�

�


�

�

�

�


�

�

�

�

�	

�

�

�


�

�

�

�

�

�

�

� �

� 

 �

 �


 �

 �

�

�	

�


�

� 

�

�

�

� �

�

 �

 �


 �

 �

� �

�$

 �

 �	

 �


 �

� �

�

 �

 �


 �

 �

�

�


�

�

�

�


�

�

�

�


�

�

� �

�%

 �,

 �

 �

 �'

 �*+

� �

�

 �

 �	

 �


 �

� �

�

 �*

 �

 �

 � %

 �()

�

�

�	

�

�

�	

�


�

�

�


�

�

� �

�

 �

 �

 �	

 �

�

�	

�


�

�

�


�

�

� �

�

 �

 �


 �

 �

�

�


�

�

�

�

�	

�

�

�


�

�

� �

�

 �

 �

 �	

 �

�

�	

�


�

�

�


�

�

� 

�

�

�

� �

�

 �*

 �

 �

 � %

 �()

�

�


�

�

� �

� 

 �

 �


 �

 �

�

�


�

�

�

�


�

�

�"

�

�

� !

�

�	

�


�

�

�


�

�

� 

�

�

�

�

�

�	

�

�"

�

�	

�!

	�

	�

	�	

	�


�


�


�	


�

�)

�

�	#

�&(

� �

�

 �

 �

 �

�

�

�

�

�

�

� �

�

 �

 �


 �

�

�

�

�

�

�

�

�

�

�

�

�

� �

�

 �

 �

 �


�

�	

�

� �

�

 �

 �

 �	

 �

 � �

 � 

  �*

  �

  �

  �%

  �()

 �

 �

 �

 �

 �

 �

 �	

 �


 �

 �

 �


 �

 �

 �

 �


 �

 �

 �

 �


 �

 �

 �

 �

 �

 �

 �

!� �

!�"

! �*

! �

! �

! �%

! �()

!�

!�

!�

!�

!�

!�

!�	

!�


!�

!�

!�


!�

!�

!�

!�


!�

!�

!�

!�


!�

!�

!�

!�

!�

!�

!�

"� �

"�

" �

" �


" �

" �

"�

"�

"�

"�

"�

#� �

#�

# �

# �	

# �


# �

#�

#�

#�	

#�

#�

#�


#�

#�

#�

#�

#�	

#�

#�

#�	

#�


#�

#�

#�


#�

#�

$� �

$�

$ �

$ �	

$ �


$ �

$�

$�


$�

$�

$�

$�


$�

$�

$�

$�


$�

$�

$�

$�


$�

$�

$�,

$�

$� 

$�!'

$�*+

%� �

%�

% �

% �	

% �


% �

%�

%�


%�

%�

%�

%�


%�

%�

%�

%�


%�

%�

%�

%�


%�

%�

%�

%�


%�

%�

%�"

%�

%�

%� !

&� �

&�

& �,

& �

& � 

& �!'

& �*+

'� �

'�

' �

' �	

' �


' �

'�

'�


'�

'�

'�

'�


'�

'�

'�

'�


'�

'�

'�

'�


'�

'�

'�

'�


'�

'�

'�

'�


'�

'�

'�

'�


'�

'�

(� �

(�

( �

( �	

( �


( �

(�

(�


(�

(�

(�%

(�

(�

(� 

(�#$

(�

(�


(�

(�

(�%

(�	

(�
 

(�#$

(�

(�


(�

(�

(�

(�


(�

(�

)� �

)�

) �

) �


) �

) �

)�$

)�

)�

)�

)�"#

)�*

)�

)�

)�%

)�()

)�

)�

)�	

)�

)�

)�


)�

)�

)� 

)�


)�

)�

)�%

)�

)�

)� 

)�#$

*� �

*�

* �

* �	

* �


* �

*�

*�


*�

*�

*�$

*�

*�

*�"#

+� �

+�

+ �

+ �

+ �

+ �

+ �

+�*

+�

+�

+� %

+�()

,� �

,�!

, �

, �	

, �


, �

,�

,�


,�

,�

,�

,�

,�

,�

,�

 � �

 �

  �G

  �

  �'

  �2E

 �H

 �

 �(

 �3F

 �K

 �

 �)

 �4I

 �Z

 �

 �:

 �EX

 �>

 �

 �)

 �4<

 �O

 �

 �3

 �>M

 �>

 �

 �)

 �4<

 �A

 �

 �%

 �0?

 �J

 �

 �.

 �9H

 	�J

 	�

 	�)

 	�4H

 
�D

 
�

 
�%

 
�0B

 �E

 �

 �&

 �1C

 �D

 �

 �(

 �3B

 �C

 �

 �&

 �1A

 �A

 �

 �"

 �-?

 �A

 �

 �#

 �.?

 �D

 �

 �(

 �3B

 �J

 �

 �.

 �9H

 �K

 �

 �/

 �:I

 �[

 �%

 �&?

 �JY

 �V

 �

 � 4

 �?T

 �O

 �

 �3

 �>M

 �T

 �

 �8

 �CR

 �H

 �

 �,

 �7F

 �A

 �

 �%

 �0?

 �O

 �

 �3

 �>M

 �O

 �

 �3

 �>M

 �d

 �

 �:

 �Eb

 �V

 �!

 �#:

 �ET

 �>

 �

 �#

 �.<

 �A

 �

 �!

 �,?

 �=

 �

 �!

 �,;

  �?

  �

  �

  �*=

 !�=

 !�

 !�"

 !�-;

 "�K

 "�

 "�/

 "�:I

 #�P

 #�

 #�4

 #�?N

 $�N

 $�

 $�.

 $�9L

 %�M

 %�

 %�1

 %�<K

 &�K

 &�

 &�/

 &�:I

 '�T

 '�

 '� 3

 '�>R

 (�B

 (�

 (�&

 (�1@

 )�5

 )�

 )�#

 )�.3

 *�C

 *�

 *�'

 *�2A

 +�B

 +�

 +�&

 +�1@

 ,�P

 ,�

 ,�4

 ,�?N

 -�U

 -�

 -�9

 -�DS

 .�H

 .�

 .�,

 .�7F

 /�L

 /�

 /�0

 /�;J

 0�L

 0�

 0�(

 0�3Jbproto3
�#
google/protobuf/struct.protogoogle.protobuf"�
Struct;
fields (2#.google.protobuf.Struct.FieldsEntryRfieldsQ
FieldsEntry
key (	Rkey,
value (2.google.protobuf.ValueRvalue:8"�
Value;

null_value (2.google.protobuf.NullValueH R	nullValue#
number_value (H RnumberValue#
string_value (	H RstringValue

bool_value (H R	boolValue<
struct_value (2.google.protobuf.StructH RstructValue;

list_value (2.google.protobuf.ListValueH R	listValueB
kind";
	ListValue.
values (2.google.protobuf.ValueRvalues*
	NullValue

NULL_VALUE B�
com.google.protobufBStructProtoPZ1github.com/golang/protobuf/ptypes/struct;structpb��GPB�Google.Protobuf.WellKnownTypesJ�
 ^
�
 2� Protocol Buffers - Google's data interchange format
 Copyright 2008 Google Inc.  All rights reserved.
 https://developers.google.com/protocol-buffers/

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

     * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following disclaimer
 in the documentation and/or other materials provided with the
 distribution.
     * Neither the name of Google Inc. nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


  

" ;
	
%" ;

# 
	
# 

$ H
	
$ H

% ,
	
% ,

& ,
	
& ,

' "
	

' "

( !
	
$( !
�
 2 5� `Struct` represents a structured data value, consisting of fields
 which map to dynamically typed values. In some languages, `Struct`
 might be supported by a native representation. For example, in
 scripting languages like JS a struct is represented as an
 object. The details of that representation are described together
 with the proto support for the language.

 The JSON representation for `Struct` is JSON object.



 2
9
  4 , Unordered map of dynamically typed values.


  4

  4

  4
�
= M� `Value` represents a dynamically typed value which can be either
 null, a number, a string, a boolean, a recursive struct value, or a
 list of values. A producer of value is expected to set one of that
 variants, absence of any variant indicates an error.

 The JSON representation for `Value` is JSON value.



=
"
 ?L The kind of value.


 ?
'
 A Represents a null value.


 A

 A

 A
)
C Represents a double value.


C


C

C
)
E Represents a string value.


E


E

E
*
G Represents a boolean value.


G

G	

G
-
I  Represents a structured value.


I


I

I
-
K  Represents a repeated `Value`.


K

K

K
�
 S V� `NullValue` is a singleton enumeration to represent the null value for the
 `Value` type union.

  The JSON representation for `NullValue` is JSON `null`.



 S

  U Null value.


  U

  U
�
[ ^v `ListValue` is a wrapper around a repeated field of values.

 The JSON representation for `ListValue` is JSON array.



[
:
 ]- Repeated field of dynamically typed values.


 ]


 ]

 ]

 ]bproto3
�A
$FederatedAuthenticationService.proto2org.apache.custos.federated.authentication.servicegoogle/protobuf/struct.proto"�
ClientMetadata
	tenant_id (RtenantId
tenant_name (	R
tenantName
scope (	Rscope

tenant_uRI (	R	tenantURI
contacts (	Rcontacts
comment (	Rcomment#
redirect_uRIs (	RredirectURIs
	client_id (	RclientId!
performed_by	 (	RperformedBy"�
RegisterClientResponse
	client_id (	RclientId#
client_secret (	RclientSecret-
client_id_issued_at (RclientIdIssuedAt7
client_secret_expires_at (RclientSecretExpiresAt6
client_registration_uri (	RclientRegistrationUri"L
GetClientRequest
	tenant_id (RtenantId
	client_id (	RclientId"�
GetClientResponse
	client_id (	RclientId
client_name (	R
clientName#
redirect_uRIs (	RredirectURIs
grant_types (	R
grantTypes
scope (	Rscope-
client_id_issued_at (RclientIdIssuedAt
comment (	Rcomment#
client_secret (	RclientSecret7
client_secret_expires_at	 (RclientSecretExpiresAt6
client_registration_uri
 (	RclientRegistrationUri"r
DeleteClientRequest
	tenant_id (RtenantId
	client_id (	RclientId!
performed_by (	RperformedBy"
Empty"9
GetOperationsMetadataRequest
trace_id (RtraceId"�
OperationMetadata
event (	Revent
status (	Rstatus

time_stamp (	R	timeStamp!
performed_by (	RperformedBy"�
GetOperationsMetadataResponsea
metadata (2E.org.apache.custos.federated.authentication.service.OperationMetadataRmetadata"�
CacheManipulationRequest
	tenant_id (RtenantId'
institution_ids (	RinstitutionIds\
type (2H.org.apache.custos.federated.authentication.service.InstitutionCacheTypeRtype 
performedBy (	RperformedBy" 
Status
status (Rstatus"
InstitutionOperationResponse"�
Institution
	entity_id (	RentityId+
organization_name (	RorganizationName!
display_name (	RdisplayName
rand_s (RrandS"=
GetInstitutionsIdsAsResponse

entity_ids (	R	entityIds"~
GetInstitutionsResponsec
institutions (2?.org.apache.custos.federated.authentication.service.InstitutionRinstitutions*3
InstitutionCacheType
	WHITELIST 
BACKLIST2�
FederatedAuthenticationService�
	addClientB.org.apache.custos.federated.authentication.service.ClientMetadataJ.org.apache.custos.federated.authentication.service.RegisterClientResponse�
updateClientB.org.apache.custos.federated.authentication.service.ClientMetadata9.org.apache.custos.federated.authentication.service.Empty�
	getClientD.org.apache.custos.federated.authentication.service.GetClientRequestE.org.apache.custos.federated.authentication.service.GetClientResponse�
deleteClientG.org.apache.custos.federated.authentication.service.DeleteClientRequest9.org.apache.custos.federated.authentication.service.Empty�
getOperationMetadataP.org.apache.custos.federated.authentication.service.GetOperationsMetadataRequestQ.org.apache.custos.federated.authentication.service.GetOperationsMetadataResponse�

addToCacheL.org.apache.custos.federated.authentication.service.CacheManipulationRequest:.org.apache.custos.federated.authentication.service.Status�
removeFromCacheL.org.apache.custos.federated.authentication.service.CacheManipulationRequest:.org.apache.custos.federated.authentication.service.Status�
getFromCacheL.org.apache.custos.federated.authentication.service.CacheManipulationRequestK.org.apache.custos.federated.authentication.service.GetInstitutionsResponse�
getInstitutionsL.org.apache.custos.federated.authentication.service.CacheManipulationRequestK.org.apache.custos.federated.authentication.service.GetInstitutionsResponseBPZ./pbJ�#
 �
�
 2�
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements. See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership. The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License. You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied. See the License for the
 specific language governing permissions and limitations
 under the License.



 "
	

 "

 ;
	
  &

 
	
 


  


 

  

  

  

 

 

 


 ! +


 !

  "

  "	

  "


  "

 #

 #


 #

 #

 $

 $

 $

 $

 $

 %

 %


 %

 %

 &!

 &

 &

 &

 & 

 '

 '


 '

 '

 (&

 (

 (

 (!

 ($%

 )

 )


 )

 )

 *

 *


 *

 *


. 4


.

 /

 /


 /

 /

0

0


0

0

1"

1	

1


1 !

2'

2	

2
"

2%&

3'

3


3"

3%&


7 :


7

 8

 8	

 8


 8

9

9


9

9


< G


<

 =

 =


 =

 =

>

>


>

>

?&

?

?

?!

?$%

@$

@

@

@

@"#

A

A

A

A

A

B"

B	

B


B !

C

C


C

C

D

D


D

D

E'

E	

E
"

E%&

	F(

	F


	F"

	F%'


I M


I

 J

 J	

 J


 J

K

K


K

K

L

L


L

L


O Q


O


S U


S$

 T

 T	

 T


 T


W \


W

 X

 X


 X

 X

Y

Y


Y

Y

Z

Z


Z

Z

[

[


[

[


] _


]%

 ^,

 ^

 ^

 ^'

 ^*+


	b g


	b 

	 c

	 c	

	 c


	 c

	d(

	d

	d

	d#

	d&'

	e"

	e

	e

	e !

	f

	f


	f

	f



i k



i


 j


 j


 j	


 j


m o


m$


q v


q

 r

 r


 r

 r

s!

s


s

s 

t

t


t

t

u

u

u	

u


x z


x$

 y"

 y

 y

 y

 y !


} 


}

 ~*

 ~

 ~

 ~%

 ~()

 � �

 �&

  �D

  �

  �!

  �,B

 �6

 �

 �$

 �/4

 �A

 �

 �#

 �.?

 �;

 �

 �)

 �49

 �d

 �

 �:

 �Eb

 �?

 �

 �,

 �7=

 �D

 �

 �1

 �<B

 �R

 �

 �.

 �9P

 �U

 �

 �1

 �<Sbproto3
�
MessagingService.proto#org.apache.custos.messaging.servicegoogle/protobuf/empty.proto"�
Message!
created_time (RcreatedTime!
service_name (	RserviceName

event_type (	R	eventType
username (	Rusername
	client_id (	RclientId
	tenant_id (RtenantId\

properties (2<.org.apache.custos.messaging.service.Message.PropertiesEntryR
properties

message_id (	R	messageId=
PropertiesEntry
key (	Rkey
value (	Rvalue:8"R
MessageEnablingRequest
	tenant_id (RtenantId
	client_id (	RclientId" 
Status
status (Rstatus"/
MessageEnablingResponse
topic (	Rtopic2�
MessagingServiced
publish,.org.apache.custos.messaging.service.Message+.org.apache.custos.messaging.service.Status�
enable;.org.apache.custos.messaging.service.MessageEnablingRequest<.org.apache.custos.messaging.service.MessageEnablingResponseBPZ./pbJ�
 >
�
 2�
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements. See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership. The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License. You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied. See the License for the
 specific language governing permissions and limitations
 under the License.



 "
	

 "

 ,
	
  %

 
	
 


  (


 

   

   	

   


   

 !

 !


 !

 !

 "

 "


 "

 "

 #

 #


 #

 #

 $

 $


 $

 $

 %

 %	

 %


 %

 &'

 &

 &"

 &%&

 '

 '


 '

 '


* -


*

 +

 +	

 +


 +

,

,


,

,


/ 1


/

 0

 0

 0	

 0


3 5


3

 4

 4


 4

 4


 8 >


 8

  :)

  :

  :

  :!'

 <H

 <

 <%

 </Fbproto3
�.
EmailService.proto)org.apache.custos.messaging.email.servicegoogle/protobuf/empty.proto"�
Email!
sender_email (	RsenderEmail%
receiver_email (	RreceiverEmailY
custos_event (26.org.apache.custos.messaging.email.service.CustosEventRcustosEvent`

parameters (2@.org.apache.custos.messaging.email.service.Email.ParametersEntryR
parameters=
ParametersEntry
key (	Rkey
value (	Rvalue:8"�
EmailTemplate
template_id (R
templateIdY
custos_event (26.org.apache.custos.messaging.email.service.CustosEventRcustosEvent
subject (	Rsubject
body_params (	R
bodyParams'
receiving_users (	RreceivingUsers)
receiving_groups (	RreceivingGroups
body (	Rbody"�
EmailEnablingRequest
	tenant_id (RtenantId
	client_id (	RclientId_
email_template (28.org.apache.custos.messaging.email.service.EmailTemplateRemailTemplate"�
EmailDisablingRequest
	tenant_id (RtenantId
	client_id (	RclientId_
email_template (28.org.apache.custos.messaging.email.service.EmailTemplateRemailTemplate" 
Status
status (Rstatus"�
EmailMessageSendingRequest
	tenant_id (RtenantId
	client_id (	RclientIdJ
message (20.org.apache.custos.messaging.email.service.EmailRmessage"V
FetchEmailTemplatesRequest
	tenant_id (RtenantId
	client_id (	RclientId"u
FetchEmailTemplatesResponseV
	templates (28.org.apache.custos.messaging.email.service.EmailTemplateR	templates"T
FetchEmailFriendlyEvents
	tenant_id (RtenantId
	client_id (	RclientId"�
CustosEmailEventL
event (26.org.apache.custos.messaging.email.service.CustosEventRevent
body_params (	R
bodyParams"w
 FetchEmailFriendlyEventsResponseS
events (2;.org.apache.custos.messaging.email.service.CustosEmailEventRevents*L
CustosEvent
UNKNOWN 
NEW_USER_SIGNUP
GROUP_MEMBERSHIP_CHANGE2�
EmailService�
sendE.org.apache.custos.messaging.email.service.EmailMessageSendingRequest1.org.apache.custos.messaging.email.service.Status�
enable?.org.apache.custos.messaging.email.service.EmailEnablingRequest8.org.apache.custos.messaging.email.service.EmailTemplate~
disable@.org.apache.custos.messaging.email.service.EmailDisablingRequest1.org.apache.custos.messaging.email.service.Status�
getTemplatesE.org.apache.custos.messaging.email.service.FetchEmailTemplatesRequestF.org.apache.custos.messaging.email.service.FetchEmailTemplatesResponse�
getEmailFriendlyEventsC.org.apache.custos.messaging.email.service.FetchEmailFriendlyEventsK.org.apache.custos.messaging.email.service.FetchEmailFriendlyEventsResponseBPZ./pbJ�
 o
�
 2�
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements. See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership. The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License. You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied. See the License for the
 specific language governing permissions and limitations
 under the License.



 "
	

 "

 2
	
  %

 
	
 


  !


 

  

  

  

 

 

 

   

  

  


 # (


 #

  $

  $


  $

  $

 %'

 %

 %

 %"

 %%&

 &!

 &

 &

 & 

 ''

 '

 '"

 '%&


* 2


*

 +

 +	

 +


 +

,!

,

,

, 

-

-


-

-

.$

.

.

.

."#

/(

/

/

/#

/&'

0)

0

0

0$

0'(

1

1


1

1


4 8


4

 5

 5	

 5


 5

6

6


6

6

7%

7

7 

7#$


: >


:

 ;

 ;	

 ;


 ;

<

<


<

<

=%

=

= 

=#$


@ B


@

 A

 A

 A	

 A


E I


E"

 F

 F	

 F


 F

G

G


G

G

H

H	

H


H


K N


K"

 L

 L	

 L


 L

M

M


M

M


P R


P#

 Q(

 Q

 Q

 Q#

 Q&'


T W


T 

 U

 U	

 U


 U

V

V


V

V


	Z ]


	Z

	 [

	 [

	 [

	 [

	\$

	\

	\

	\

	\"#



_ a



_(


 `)


 `


 `


 `$


 `'(


 d o


 d

  f;

  f

  f(

  f39

 h>

 h

 h$

 h/<

 j9

 j

 j&

 j17

 lX

 l

 l0

 l;V

 nc

 n

 n7

 nAabproto3
�u
,src/main/proto/TenantManagementService.proto+org.apache.custos.tenant.management.servicegoogle/api/annotations.protoTenantProfileService.protogoogle/rpc/error_details.protogoogle/protobuf/empty.protoIamAdminService.proto$FederatedAuthenticationService.protoMessagingService.protoEmailService.proto"�
CreateTenantResponse
	client_id (	RclientId#
client_secret (	RclientSecret!
is_activated (RisActivated-
client_id_issued_at (RclientIdIssuedAt7
client_secret_expires_at (RclientSecretExpiresAt6
registration_client_uri (	RregistrationClientUri;
token_endpoint_auth_method (	RtokenEndpointAuthMethod
msg (	Rmsg"�
GetTenantResponse
	client_id (	RclientId
client_name (	R
clientName'
requester_email (	RrequesterEmail(
admin_first_name (	RadminFirstName&
admin_last_name (	RadminLastName
admin_email (	R
adminEmail
contacts (	Rcontacts#
redirect_uris (	RredirectUris
grant_types	 (	R
grantTypes-
client_id_issued_at
 (RclientIdIssuedAt

client_uri (	R	clientUri
scope (	Rscope
domain (	Rdomain
comment (	Rcomment
logo_uri (	RlogoUri)
application_type (	RapplicationType
jwks_uri (	RjwksUri>
example_extension_parameter (	RexampleExtensionParameter
tos_uri (	RtosUri

policy_uri (	R	policyUri\
jwks (2H.org.apache.custos.tenant.management.service.GetTenantResponse.JwksEntryRjwks
software_id (	R
softwareId)
software_version (	RsoftwareVersion%
admin_username (	RadminUsername7
	JwksEntry
key (	Rkey
value (	Rvalue:8"�
GetTenantRequest
	client_id (	RclientId
	tenant_id (RtenantIdH
tenant (20.org.apache.custos.tenant.profile.service.TenantRtenantZ
credentials (28.org.apache.custos.tenant.management.service.CredentialsRcredentials"�
Credentials"
iam_client_id (	RiamClientId*
iam_client_secret (	RiamClientSecret+
ci_logon_client_id (	RciLogonClientId3
ci_logon_client_secret (	RciLogonClientSecret(
custos_client_id (	RcustosClientId0
custos_client_secret (	RcustosClientSecret:
custos_client_id_issued_at (RcustosClientIdIssuedAtD
custos_client_secret_expired_at (RcustosClientSecretExpiredAt"�
UpdateTenantRequest
	client_id (	RclientId
	tenant_id (RtenantIdZ
credentials (28.org.apache.custos.tenant.management.service.CredentialsRcredentialsD
body (20.org.apache.custos.tenant.profile.service.TenantRbody"�
DeleteTenantRequest
	client_id (	RclientId
	tenant_id (RtenantIdZ
credentials (28.org.apache.custos.tenant.management.service.CredentialsRcredentialsD
body (20.org.apache.custos.tenant.profile.service.TenantRbody"4
GetCredentialsRequest
	tenant_id (RtenantId"�
GetCredentialsResponse"
iam_client_id (	RiamClientId*
iam_client_secret (	RiamClientSecret+
ci_logon_client_id (	RciLogonClientId3
ci_logon_client_secret (	RciLogonClientSecret"U
TenantValidationRequest
	client_id (	RclientId

client_sec (	R	clientSec2�&
TenantManagementService�
createTenant0.org.apache.custos.tenant.profile.service.TenantA.org.apache.custos.tenant.management.service.CreateTenantResponse"/���)"'/tenant-management/v1.0.0/oauth2/tenant�
	getTenant=.org.apache.custos.tenant.management.service.GetTenantRequest0.org.apache.custos.tenant.profile.service.Tenant"/���)'/tenant-management/v1.0.0/oauth2/tenant�
updateTenant@.org.apache.custos.tenant.management.service.UpdateTenantRequest0.org.apache.custos.tenant.profile.service.Tenant"5���/'/tenant-management/v1.0.0/oauth2/tenant:body�
deleteTenant@.org.apache.custos.tenant.management.service.DeleteTenantRequest.google.protobuf.Empty"/���)*'/tenant-management/v1.0.0/oauth2/tenant�
validateTenantD.org.apache.custos.tenant.management.service.TenantValidationRequest..org.apache.custos.iam.service.OperationStatus";���5"3/tenant-management/v1.0.0/tenant/credentials/status�
addTenantRoles..org.apache.custos.iam.service.AddRolesRequest'.org.apache.custos.iam.service.AllRoles"'���!"/tenant-management/v1.0.0/roles�
getTenantRoles..org.apache.custos.iam.service.GetRolesRequest'.org.apache.custos.iam.service.AllRoles"'���!/tenant-management/v1.0.0/roles�

deleteRole0.org.apache.custos.iam.service.DeleteRoleRequest..org.apache.custos.iam.service.OperationStatus"&��� */tenant-management/v1.0.0/role�
addProtocolMapper7.org.apache.custos.iam.service.AddProtocolMapperRequest..org.apache.custos.iam.service.OperationStatus"1���+")/tenant-management/v1.0.0/protocol/mapper�
configureEventPersistence6.org.apache.custos.iam.service.EventPersistenceRequest..org.apache.custos.iam.service.OperationStatus"(���"" /tenant-management/v1.0.0/events�
enableMessaging;.org.apache.custos.messaging.service.MessageEnablingRequest<.org.apache.custos.messaging.service.MessageEnablingResponse"+���%"#/tenant-management/v1.0.0/messaging�
updateTenantStatus=.org.apache.custos.tenant.profile.service.UpdateStatusRequest>.org.apache.custos.tenant.profile.service.UpdateStatusResponse"(���"" /tenant-management/v1.0.0/status�
getAllTenants;.org.apache.custos.tenant.profile.service.GetTenantsRequest?.org.apache.custos.tenant.profile.service.GetAllTenantsResponse")���#!/tenant-management/v1.0.0/tenants�
getChildTenants;.org.apache.custos.tenant.profile.service.GetTenantsRequest?.org.apache.custos.tenant.profile.service.GetAllTenantsResponse"/���)'/tenant-management/v1.0.0/child/tenants�
getAllTenantsForUserE.org.apache.custos.tenant.profile.service.GetAllTenantsForUserRequestF.org.apache.custos.tenant.profile.service.GetAllTenantsForUserResponse":���42/tenant-management/v1.0.0/tenants/{requesterEmail}�
getTenantStatusUpdateAuditTrail>.org.apache.custos.tenant.profile.service.GetAuditTrailRequestK.org.apache.custos.tenant.profile.service.GetStatusUpdateAuditTrailResponse"9���31/tenant-management/v1.0.0/audit/status/{tenantId}�
"getTenantAttributeUpdateAuditTrail>.org.apache.custos.tenant.profile.service.GetAuditTrailRequestN.org.apache.custos.tenant.profile.service.GetAttributeUpdateAuditTrailResponse"=���75/tenant-management/v1.0.0/audit/attributes/{tenantId}�

addToCacheL.org.apache.custos.federated.authentication.service.CacheManipulationRequest:.org.apache.custos.federated.authentication.service.Status"<���6"4/tenant-management/v1.0.0/cache/institutions/CILogon�
removeFromCacheL.org.apache.custos.federated.authentication.service.CacheManipulationRequest:.org.apache.custos.federated.authentication.service.Status"<���6*4/tenant-management/v1.0.0/cache/institutions/CILogon�
getFromCacheL.org.apache.custos.federated.authentication.service.CacheManipulationRequestK.org.apache.custos.federated.authentication.service.GetInstitutionsResponse"<���64/tenant-management/v1.0.0/cache/institutions/CILogon�
getInstitutionsL.org.apache.custos.federated.authentication.service.CacheManipulationRequestK.org.apache.custos.federated.authentication.service.GetInstitutionsResponse"6���0./tenant-management/v1.0.0/institutions/CILogon�
enableEmail?.org.apache.custos.messaging.email.service.EmailEnablingRequest8.org.apache.custos.messaging.email.service.EmailTemplate"2���,"*/tenant-management/v1.0.0/email/activation�
disableEmail@.org.apache.custos.messaging.email.service.EmailDisablingRequest1.org.apache.custos.messaging.email.service.Status"4���.",/tenant-management/v1.0.0/email/deactivation�
getEmailTemplatesE.org.apache.custos.messaging.email.service.FetchEmailTemplatesRequestF.org.apache.custos.messaging.email.service.FetchEmailTemplatesResponse"1���+)/tenant-management/v1.0.0/email/templates�
getEmailFriendlyEventsC.org.apache.custos.messaging.email.service.FetchEmailFriendlyEventsK.org.apache.custos.messaging.email.service.FetchEmailFriendlyEventsResponse".���(&/tenant-management/v1.0.0/email/eventsBPZ./pbJ�6
 �
�
 2�
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements. See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership. The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License. You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied. See the License for the
 specific language governing permissions and limitations
 under the License.



 "
	

 "

 4

 
	
 
	
  &
	
 $
	
 (
	
 %
	
 
	
 .
	
   
	
! 


 $ -


 $

  %

  %


  %

  %

 &

 &


 &

 &

 '

 '

 '	

 '

 (#

 (


 (

 (!"

 )(

 )


 )#

 )&'

 *'

 *


 *"

 *%&

 ++

 +


 +%

 +(*

 ,

 ,


 ,

 ,


/ H


/

 0

 0


 0

 0

1

1


1

1

2

2


2

2

3 

3


3

3

4

4


4

4

5

5


5

5

6!

6

6

6

6 

7&

7

7

7!

7$%

8$

8

8

8

8"#

	9$

	9


	9

	9!#


:


:



:


:

;

;


;

;

<

<


<

<

=

=


=

=

>

>


>

>

?!

?


?

? 

@

@


@

@

A,

A


A&

A)+

B

B


B

B

C

C


C

C

D"

D

D

D!

E

E


E

E

F!

F


F

F 

G

G


G

G


K P


K

 L

 L


 L

 L

M

M	

M


M

N?

N3

N4:

N=>

O 

O

O

O


S \


S

 T

 T


 T

 T

U!

U


U

U 

V"

V


V

V !

W&

W


W!

W$%

X 

X


X

X

Y$

Y


Y

Y"#

Z*

Z


Z%

Z()

[/

[


[*

[-.


^ c


^

 _

 _


 _

 _

`

`	

`


`

a 

a

a

a

b=

b3

b48

b;<


f k


f

 g

 g


 g

 g

h

h	

h


h

i 

i

i

i

j=

j3

j48

j;<


n p


n

 o

 o	

 o


 o


r w


r

 s

 s


 s

 s

t!

t


t

t 

u"

u


u

u !

v&

v


v!

v$%


z ~


z

 {

 {


 {

 {

|

|


|

|

 � �

 �

  ��

  �

  �E

  �Pd

  ��

	  �ʼ"��

 ��

 �

 �#

 �.]

 ��


	 �ʼ"��


 ��

 �

 �)

 �4c

 ��


	 �ʼ"��


 ��

 �

 �)

 �4I

 ��


	 �ʼ"��


 ��

 �

 �/

 �:g

 ��


	 �ʼ"��


 ��

 �

 �E

 �Pv

 ��


	 �ʼ"��


 ��

 �

 �E

 �Pv

 ��


	 �ʼ"��


 ��

 �

 �C

 �N{

 ��


	 �ʼ"��


 ��

 �

 �Q

 �\�

 ��


	 �ʼ"��


 	��

 	�!

 	�#X

 	�c�

 	��


	 	�ʼ"��


 
��

 
�

 
�R

 
�]�

 
��


	 
�ʼ"��


 ��

 �

 �X

 �c�

 ��


	 �ʼ"��


 ��

 �

 �Q

 �\�

 ��


	 �ʼ"��


 ��

 �

 �S

 �^�

 ��


	 �ʼ"��


 ��

 �

 �b

 �m�

 ��


	 �ʼ"��


 ��

 �'

 �)f

 �q�

 ��


	 �ʼ"��


 ��

 �*

 �,i

 �t�

 ��


	 �ʼ"��


 ��

 �

 �_

 �j�

 ��


	 �ʼ"��


 ��

 �

 �d

 �o�

 ��


	 �ʼ"��


 ��

 �

 �a

 �l�

 ��


	 �ʼ"��


 ��

 �

 �d

 �o�

 ��


	 �ʼ"��


 ��

 �

 �R

 �]�

 ��


	 �ʼ"��


 ��

 �

 �T

 �_�

 ��


	 �ʼ"��


 ��

 �

 �^

 �i�

 ��


	 �ʼ"��


 ��

 �

 �a

 �l�

 ��


	 �ʼ"��
bproto3