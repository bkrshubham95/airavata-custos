/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements. See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership. The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License. You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied. See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */

package org.apache.custos.resource.secret.persistance.local.repository;

import org.apache.custos.resource.secret.persistance.local.model.Secret;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Iterator;
import java.util.List;

public interface SecretRepository extends JpaRepository<Secret, String> {


    public List<Secret> findAllByExternalIdAndOwnerIdAndTenantId(String externalId, String ownerId, long tenantId);

    public List<Secret> findAllByExternalIdAndTenantId(String externalId, long tenantId);

    @Query(value = "select * from secret s where s.tenant_id = ?1 and ( s.id  IN ?2 " +
            "or s.external_id  IN ?3 )", nativeQuery = true)
    public List<Secret> getAllSecretsByIdOrExternalId(long tenantId, List<String> tokens, List<String> externalIds);


}
