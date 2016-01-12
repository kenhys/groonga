/* -*- c-basic-offset: 2 -*- */
/*
  Copyright(C) 2009-2016 Brazil

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License version 2.1 as published by the Free Software Foundation.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

#include "grn_ctx_impl.h"
#include "grn_db.h"

grn_obj *
grn_type_create(grn_ctx *ctx, const char *name, unsigned int name_size,
                grn_obj_flags flags, unsigned int size)
{
  grn_id id;
  struct _grn_type *res = NULL;
  grn_obj *db;
  if (!ctx || !ctx->impl || !(db = ctx->impl->db)) {
    ERR(GRN_INVALID_ARGUMENT, "db not initialized");
    return NULL;
  }
  GRN_API_ENTER;
  if (grn_db_check_name(ctx, name, name_size)) {
    GRN_DB_CHECK_NAME_ERR("[type][create]", name, name_size);
    GRN_API_RETURN(NULL);
  }
  if (!GRN_DB_P(db)) {
    ERR(GRN_INVALID_ARGUMENT, "invalid db assigned");
    GRN_API_RETURN(NULL);
  }
  id = grn_obj_register(ctx, db, name, name_size);
  if (id && (res = GRN_MALLOC(sizeof(grn_db_obj)))) {
    GRN_DB_OBJ_SET_TYPE(res, GRN_TYPE);
    res->obj.header.flags = flags;
    res->obj.header.domain = GRN_ID_NIL;
    GRN_TYPE_SIZE(&res->obj) = size;
    if (grn_db_obj_init(ctx, db, id, DB_OBJ(res))) {
      // grn_obj_delete(ctx, db, id);
      GRN_FREE(res);
      GRN_API_RETURN(NULL);
    }
  }
  GRN_API_RETURN((grn_obj *)res);
}

