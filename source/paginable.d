interface Paginable
{
    /**
      Set the height (in number of lines) of the window where the
      document will show up.

      Params:
        lines = the height in lines.
      Returns: the number of pages of the document (same as `totalPage()`).

    */
    ulong setPageHeight(uint lines);

    /**
      Get the number of pages of the document.

      Throws: throws nothing.
      Returns: the number of pages of the document.
    */
    ulong getTotalPages() nothrow const;

    /**
      Get the index (1 based) of the document.

      Throws: throws nothing.
      Returns: the content of the current page.
    */
    ulong getCurrentPage() nothrow const;

    /**
      Set the current page of the document.

      A newly created document has its current page default to 1.
      If the page is out of bounds, it wont be changed.

      Params:
        page = the index (1 based) of the new page.
      Throws: throws nothing.
      Returns: the index (1 based) of the new current page.
    */
    ulong setCurrentPage(ulong page) nothrow;

    string getCurrentPageContent() const;
}
