/* -*- c-basic-offset: 2 -*- */
/* Copyright(C) 2011 Brazil

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License version 2.1 as published by the Free Software Foundation.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/
#ifndef GRN_DAT_H
#define GRN_DAT_H

#ifndef GROONGA_IN_H
#include "groonga_in.h"
#endif /* GROONGA_IN_H */

#include "db.h"

#ifdef __cplusplus
extern "C" {
#endif

struct _grn_dat {
  grn_db_obj obj;
  grn_io *io;
  struct grn_dat_header *header;
  uint32_t file_id;
  grn_encoding encoding;
  void *trie;
  void *old_trie;
  grn_obj *tokenizer;
  grn_critical_section lock;
};

struct grn_dat_header {
  uint32_t flags;
  grn_encoding encoding;
  grn_id tokenizer;
  uint32_t file_id;
};

struct _grn_dat_cursor {
  grn_db_obj obj;
  grn_dat *dat;
  void *cursor;
  const void *key;
  grn_id curr_rec;
};

typedef struct _grn_dat_scan_hit grn_dat_scan_hit;

struct _grn_dat_scan_hit {
  grn_id id;
  unsigned int offset;
  unsigned int length;
};

int grn_dat_scan(grn_ctx *ctx, grn_dat *dat, const char *str,
                 unsigned int str_size, grn_dat_scan_hit *scan_hits,
                 unsigned int max_num_scan_hits, const char **str_rest);
grn_id grn_dat_lcp_search(grn_ctx *ctx, grn_dat *dat,
                          const void *key, unsigned int key_size);

grn_id grn_dat_curr_id(grn_ctx *ctx, grn_dat *dat);

/*
  Currently, grn_dat_truncate() is available if the grn_dat object is
  associated with a file.
 */
grn_rc grn_dat_truncate(grn_ctx *ctx, grn_dat *dat);

const char *_grn_dat_key(grn_ctx *ctx, grn_dat *dat, grn_id id, uint32_t *key_size);
grn_id grn_dat_next(grn_ctx *ctx, grn_dat *dat, grn_id id);
grn_id grn_dat_at(grn_ctx *ctx, grn_dat *dat, grn_id id);

grn_rc grn_dat_clear_status_flags(grn_ctx *ctx, grn_dat *dat);

/*
  Currently, grn_dat_repair() is available if the grn_dat object is associated
  with a file.
 */
grn_rc grn_dat_repair(grn_ctx *ctx, grn_dat *dat);

#ifdef __cplusplus
}
#endif

#endif /* GRN_DAT_H */
