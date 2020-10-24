//компиляция этого файла gcc -I/usr/include/postgresql/12/server/ -fPIC -c point.c
//gcc -shared -o point.so point.o


#include <postgres.h>
#include <fmgr.h>
#include <libpq/pqformat.h>
#include <math.h>

PG_MODULE_MAGIC;

typedef struct point{
    double x, y, z;    
} point;

PG_FUNCTION_INFO_V1(point_in);

Datum point_in(PG_FUNCTION_ARGS)
{
	char *s = PG_GETARG_CSTRING(0);

	point *v = (point*)palloc(sizeof(point));

	if (sscanf(s, "(%lf,%lf,%lf)", &(v->x), &(v->y), &(v->z)) != 3)
	{
		ereport(ERROR, (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION), errmsg("Invalid input syntax for point: \"%s\"", s)));
	}

	PG_RETURN_POINTER(v);
}

//snprintf Она идентична функции sprintf() за исключением того, что в массиве, адресуемом указателем buf, будет сохранено максимум num-1 символов.
// По окончании работы функции этот массив будет завершаться символом конца строки (нуль-символом).
// Таким образом, функция snprintf() позволяет предотвратить переполнение буфера buf.

PG_FUNCTION_INFO_V1(point_out);

Datum point_out(PG_FUNCTION_ARGS)
{
	point *v = (point*)PG_GETARG_POINTER(0);

	char *s = (char*)palloc(100);

	snprintf(s, 100, "(%lf,%lf,%lf)", v->x, v->y, v->z);

	PG_RETURN_CSTRING(s);
}


